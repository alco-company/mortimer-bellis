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
    around_action :user_time_zone # if Current.user || Current.tenant
  end

  class Resolver
    def self.call(params: {}, request: nil, user: nil, tenant: nil)
      user ||= Current.user
      tenant ||= Current.tenant
      (normalize(params.dig(:locale)) rescue false) ||
      (normalize(params.dig(:lang)) rescue false) ||
      normalize(user&.locale) ||
      normalize(tenant&.locale) ||
      normalize(extract_from_tld(request)) ||
      I18n.default_locale
    end

    def self.normalize(val)
      return nil if val.blank?
      code =
        case val
        when Symbol, String then val.to_s
        else
          val.respond_to?(:code)   ? val.code.to_s   :
          val.respond_to?(:locale) ? val.locale.to_s :
          val.respond_to?(:to_str) ? val.to_str      : nil
        end
      return nil if code.blank?
      code = code.tr("-", "_")
      short = code.split("_").first
      [ code, short ].each do |c|
        sym = c.to_s.downcase.to_sym
        return sym if I18n.available_locales.include?(sym)
      end
      nil
    end

    private_class_method :normalize

    def self.extract_from_tld(request)
      return nil unless request
      request.host.split(".").last&.tr("-", "_") rescue nil
    end

    private_class_method :extract_from_tld
  end


  private

    #
    # switch locale to user preferred language - or by params[:locale]
    # https://phrase.com/blog/posts/rails-i18n-best-practices/
    #
    def switch_locale(&action)
      locale = get_locale

      I18n.with_locale(locale, &action)
    rescue I18n::InvalidLocale => e
      # Fallback to default rather than 500
      Rails.logger.warn("Invalid locale #{locale.inspect}: #{e.message}")
      I18n.with_locale(I18n.default_locale, &action)
    rescue => e
      UserMailer.error_report(e.to_s, "TimezoneLocale#switch_locale - failed with params: #{params}").deliver_later
      I18n.with_locale(I18n.default_locale, &action)
    end

    def get_locale
      TimezoneLocale::Resolver.call(
        params: params,
        request: request,
        user: Current.user,
        tenant: Current.tenant
      )

      # normalize_locale(params[:locale]) ||
      # normalize_locale(params[:lang]) ||
      # get_locale_from_user_or_tenant ||
      # extract_locale_from_tld ||
      # I18n.default_locale
    end

    # Get locale from top-level domain or return +nil+ if such locale is not available
    # You have to put something like:
    #   127.0.0.1 application.com
    #   127.0.0.1 application.it
    #   127.0.0.1 application.pl
    # in your /etc/hosts file to try this out locally
    def extract_locale_from_tld
      parsed = request.host.split(".").last rescue nil
      return nil unless parsed
      parsed = parsed.tr("-", "_")
      short = parsed.split("_").first
      [ parsed, short ].find { |code| I18n.available_locales.include?(code.to_sym) }
    end

    def get_locale_from_user_or_tenant
      normalize_locale(Current.user&.locale) ||
      normalize_locale(Current.tenant&.locale)
    end

    # Accept objects (e.g., Localeable::Locale), strings ("da", "da-DK"), or symbols.
    def normalize_locale(val)
      return nil if val.blank?
      code =
        if val.is_a?(Symbol) || val.is_a?(String)
          val.to_s
        elsif val.respond_to?(:code)
          val.code.to_s
        elsif val.respond_to?(:locale)
          val.locale.to_s
        elsif val.respond_to?(:to_str)
          val.to_str
        else
          nil
        end
      return nil if code.blank?

      code = code.tr("-", "_")
      short = code.split("_").first
      [ code, short ].each do |c|
        sym = c.to_s.downcase.to_sym
        return sym if I18n.available_locales.include?(sym)
      end
      nil
    end

    #
    # make sure we use the timezone (of the current_user)
    #
    def user_time_zone(&block)
      # timezone = Current.user&.time_zone || Current.tenant&.time_zone rescue nil
      # timezone.blank? ?
      #   Time.use_zone("Europe/Copenhagen", &block) :
      #   Time.use_zone(timezone, &block)
      # Accept either `time_zone` or `timezone` attribute names.
      zone =
        Current.user&.try(:time_zone).presence ||
        Current.user&.try(:timezone).presence ||
        Current.tenant&.try(:time_zone).presence ||
        Current.tenant&.try(:timezone).presence ||
        "Europe/Copenhagen"

      zone = "Europe/Copenhagen" unless ActiveSupport::TimeZone[zone] # fallback if invalid
      Time.use_zone(zone, &block)
    rescue => e
      # Fallback hard and still run the action
      Time.use_zone("Europe/Copenhagen", &block)
    end
end
