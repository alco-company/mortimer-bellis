class TenantBackupsController < MortimerController
  #
  # defined in the batch_actions concern
  skip_before_action :set_batch, only: %i[ new index destroy] # new b/c of modal
  #
  # defined in the resourceable concern
  skip_before_action :set_resource, only: %i[ new show edit update destroy ]
  skip_before_action :set_filter, only: %i[ new index destroy ] # new b/c of modal
  skip_before_action :set_resources, only: %i[ index destroy ]
  skip_before_action :set_resources_stream
  skip_before_action :set_user_resources_stream, only: %i[ index ]

  #
  # GET /tenant_backups/tenant_1_20251121071300.tar.gz
  #
  def download
    filename = params[:filename]

      # Security: validate filename format (tenant_ID_TIMESTAMP.tar.gz or tenant_ID_TIMESTAMP_report.pdf)
      unless filename.match?(/\Atenant_\d+_\d{14}(\.tar\.gz|_report\.pdf)\z/)
      return head :not_found
      end

    file_path = Rails.root.join("storage", "tenant_backups", filename)

    # Check file exists
    unless File.exist?(file_path)
      return head :not_found
    end

    # Security: ensure user belongs to the tenant in the filename
    tenant_id = filename.match(/tenant_(\d+)_/)[1].to_i
    unless Current.tenant&.id == tenant_id
      return head :forbidden
    end

      mime_type = filename.end_with?(".pdf") ? "application/pdf" : "application/gzip"
      send_file file_path,
                filename: filename,
                type: mime_type,
                disposition: "attachment"
  end

  # #<ActionController::Parameters {"controller"=>"tenant_backups", "action"=>"restore", "filename"=>"tenant_1_20251124104900.tar.gz"} permitted: false>
  def restore
    tenant_id = Current.get_tenant.id
    archive = Rails.root.join("storage", "tenant_backups", "#{params.dig(:filename)}").to_s
    raise "Archive file not found" unless File.exist?(archive)

    puts "[rake restore] DB path: #{ActiveRecord::Base.connection_db_config.configuration_hash[:database]} ENV=#{Rails.env}"

    tenant = Tenant.find(tenant_id)
    user = Current.user
    dry_run = false # env_bool("DRY_RUN", false) - @args.fetch(:dry_run, false) || ENV["DRY_RUN"] == "1"
    purge = true # purge = env_bool("PURGE", false) - @args.fetch(:purge, false) && !setting(:dry_run)
    strict = false # env_bool("STRICT", false) - @args.fetch(:strict, false)
    restore_flag = true # env_bool("RESTORE", true) - @args.fetch(:restore, true)
    # @args.fetch(:remap, true) && !setting(:dry_run)
    remap = false # env_bool("REMAP", true) unless defined?(remap) && remap == true - setting(:remap) && @args.fetch(:allow_remap, true) && ENV["RESTORE_NO_REMAP"] != "1"
    skip_email = false # env_bool("SKIP_EMAIL", false)
    perform_now = false # env_bool("PERFORM_NOW", false) || env_bool("NOW", false) || env_bool("SYNC", false)
    # @args.fetch(:skip_models, "").to_s.split(",").map { |m| m.strip }.reject(&:blank?)
    # @args.fetch(:update_tenant, true)

    # Force using the write connection to avoid readonly mode errors
    ActiveRecord::Base.connected_to(role: :writing) do
      bg = BackgroundJob.create!(tenant: tenant, user: user, job_klass: "RestoreTenantJob", state: :planned)
      if perform_now
        jid = "inline-#{SecureRandom.hex(6)}"
        bg.update_column(:job_id, jid)
        bg.update!(state: :running)
        job = RestoreTenantJob.new
        job.instance_variable_set(:@job_id, jid)
        job.perform(tenant: tenant, user: user, archive_path: archive, strict: strict, dry_run: dry_run, purge: purge, restore: restore_flag, remap: remap, skip_email: skip_email, background_job: bg)
        bg.update!(state: :finished)
        bg.job_done
        puts "Ran RestoreTenantJob inline job_id=#{jid} background_job_id=#{bg.id} dry_run=#{dry_run} purge=#{purge} restore=#{restore_flag} remap=#{remap}"
      else
        job = RestoreTenantJob.perform_now(tenant: tenant, user: user, archive_path: archive, strict: strict, dry_run: dry_run, purge: purge, restore: restore_flag, remap: remap, skip_email: skip_email, background_job: bg)
        bg.update_column(:job_id, job.job_id)
        puts "Enqueued RestoreTenantJob job_id=#{job.job_id} background_job_id=#{bg.id} dry_run=#{dry_run} purge=#{purge} restore=#{restore_flag} remap=#{remap}"
      end
    end

    terminate_session # sign_out(Current.user)
    flash.now[:alert] = "Data are being restored. Please sign in again after a few minutes."
    redirect_to new_users_session_url
  end
end
