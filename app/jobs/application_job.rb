class ApplicationJob < ActiveJob::Base
  include Alco::SqlStatements
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  #
  # most jobs will need to know what account and user they are working with
  # - so jobs inheriting from this will call super(args)
  #
  def perform **args
    account = args[:account] || Account.find(args[:account_id]) rescue Account.first
    Current.account = account
    # Current.user = args[:user] || User.unscoped.find( args[:user_id] ) rescue User.first
  rescue => exception
    say exception
  end
  #
  # allow jobs to say what they need to say
  #
  def say(msg)
    Rails.logger.info "----------------------------------------------------------------------"
    Rails.logger.info msg
    Rails.logger.info "----------------------------------------------------------------------"
  end

  def switch_locale(&action)
    # locale = Current.user.profile.locale rescue set_user_locale
    locale ||= (locale || I18n.default_locale)
    I18n.with_locale(locale, &action)
  end

  private
end
