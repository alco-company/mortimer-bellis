class ApplicationMailer < ActionMailer::Base
  default from: ->(address = nil) { build_default_from_address }
  layout "mailer"

  def switch_locale(&action)
    locale = Current.user.locale rescue nil
    locale ||= (Current.locale || I18n.default_locale)
    I18n.with_locale(locale, &action)
  end

  private
    def build_default_from_address(address = nil)
      address ||= ENV["SMTP_USER_NAME"]
      email_address_with_name address, "Mortimer Pro"
    end
end
