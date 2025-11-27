#
# ENV["FALLBACK_LOG"] turns on fallback logging on background_jobs
#
class ApplicationJob < ActiveJob::Base
  include Alco::SqlStatements

  attr_accessor :tenant, :user, :background_job

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  after_perform :mark_job_completed
  before_perform :mark_job_started

  #
  # most jobs will need to know what tenant and user they are working with
  # - so jobs inheriting from this will call super(args)
  #
  def perform(**args)
    @tenant = args[:tenant] || Tenant.find(args[:tenant_id]) rescue Tenant.first
    @user = args[:user] || User.find(args[:user_id]) || tenant.users.first rescue User.first
    @background_job = args[:background_job] if args[:background_job].is_a?(BackgroundJob)
    Current.system_user = @user
  rescue => exception
    say exception
  end
  #
  # allow jobs to say what they need to say
  #
  def say(msg)
    Rails.logger.info { "----------------------------------------------------------------------" }
    Rails.logger.info { msg }
    Rails.logger.info { "----------------------------------------------------------------------" }
  end

  def switch_locale(locale = nil, &action)
    # locale = Current.user.profile.locale rescue set_user_locale
    locale ||= (locale || I18n.default_locale)
    I18n.with_locale(locale, &action)
  end

  def user_time_zone(tz = nil, &block)
    timezone = tz || Current.user.time_zone || Current.tenant.time_zone rescue nil
    timezone.blank? ?
      Time.use_zone("Europe/Copenhagen", &block) :
      Time.use_zone(timezone, &block)
  end


  def log_progress(summary, step:, **data)
    payload = { step: step, at: Time.now.utc.iso8601 }.merge(data)
    # Add step information to summary array for tests
    summary << payload.dup if summary.is_a?(Array)

    begin
      if @background_job
        current = JSON.parse(@background_job.job_progress || "{}") rescue {}
        current["log"] ||= []
        current["log"] << payload
        current["log"] = current["log"].last(200)
        # Store only important summary items (skip per-table details to avoid bloat)
        # Keep items with keys like: step, error, purge_complete, restore_scenario, etc.
        # Skip items with keys like: table, model, file (per-table processing details)
        if summary.is_a?(Array)
          important_summary = summary.select do |item|
            next false unless item.is_a?(Hash)
            # Keep items that don't have 'table' or 'model' keys (these are per-table details)
            # Or keep items with error/warning/complete keys (these are important)
            !item.key?(:table) || item.keys.any? { |k| k.to_s.match?(/_error|_warning|_complete|_stats/) }
          end
          current["summary"] = important_summary.last(100)
        end
        @background_job.update_column(:job_progress, current.to_json)
        append_fallback_log(payload.merge(summary: summary.last(5))) if fallback_log_enabled?
      elsif fallback_log_enabled?
        append_fallback_log(payload.merge(summary: summary.last(5)))
      end
    rescue => e
      append_fallback_log(payload.merge(error: e.message)) if fallback_log_enabled?
    end
    summary = []
  end


  private

    def mark_job_started
      # Find the background job record that scheduled this job
      bg = @background_job # BackgroundJob.find_by(job_id: job_id) if job_id
      if bg
        bg.update!(state: :running) unless bg.running?
        Broadcasters::Resource.new(bg, bg.get_parms, user: bg.tenant.users.first, stream: "#{bg.tenant.id}_background_jobs").replace
      end
    end

    def mark_job_completed
      bg = @background_job # BackgroundJob.find_by(job_id: job_id) if job_id
      if bg
        bg.job_done
        Broadcasters::Resource.new(bg, bg.get_parms, user: bg.tenant.users.first, stream: "#{bg.tenant.id}_background_jobs").replace
      end
    end

    def fallback_log_enabled?
      ENV["FALLBACK_LOG"].present?
    end

    def fallback_log_path
      @fallback_log_path ||= Rails.root.join("tmp", "background_job_fallback_#{Time.now.utc.strftime("%Y%m%d")}.log")
    end

    def append_fallback_log(entry)
      File.open(fallback_log_path, "a") { |f| f.puts(entry.to_json) }
    rescue
    end
end
