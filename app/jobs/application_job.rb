class ApplicationJob < ActiveJob::Base
  include Alco::SqlStatements

  attr_accessor :tenant, :user

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  #
  # most jobs will need to know what tenant and user they are working with
  # - so jobs inheriting from this will call super(args)
  #
  def perform **args
    @tenant = args[:tenant] || Tenant.find(args[:tenant_id]) rescue Tenant.first
    @user = args[:user] || User.find(args[:user_id]) || tenant.users.first rescue User.first
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


  private
end
