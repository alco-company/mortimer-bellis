module TimezoneLocale
  extend ActiveSupport::Concern

  included do
    #
    # handling locale
    #
    around_action :switch_locale

    #
    # about handling date and timezone
    # https://nandovieira.com/working-with-dates-on-ruby-on-rails
    #
    around_action :user_time_zone
  end



  private

    #
    # switch locale to user preferred language - or by params[:locale]
    # https://phrase.com/blog/posts/rails-i18n-best-practices/
    #
    def switch_locale(&action)
      locale = extract_locale_from_tld || I18n.default_locale
      locale = params[:locale] || locale
      # locale = current_user.preferred_locale if current_user rescue locale
      parsed_locale = get_locale_from_user_or_account || locale
      I18n.with_locale(parsed_locale, &action)
    end

    # Get locale from top-level domain or return +nil+ if such locale is not available
    # You have to put something like:
    #   127.0.0.1 application.com
    #   127.0.0.1 application.it
    #   127.0.0.1 application.pl
    # in your /etc/hosts file to try this out locally
    def extract_locale_from_tld
      parsed_locale = request.host.split(".").last
      I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
    end

    def get_locale_from_user_or_account
      Current.user&.locale || Current.account&.locale
    end

    #
    # make sure we use the timezone (of the current_user)
    #
    def user_time_zone(&block)
      timezone = Current.user.time_zone || Current.account.time_zone rescue nil
      timezone.blank? ?
        Time.use_zone("Europe/Copenhagen", &block) :
        Time.use_zone(timezone, &block)
    end
end
