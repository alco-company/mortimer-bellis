class ApplicationMailer < ActionMailer::Base
  default from: ->(address = nil) { build_default_from_address }
  layout "mailer"

  def set_locale
    I18n.locale = TimezoneLocale::Resolver.call(params: params[:params], user: @user, tenant: @user.try(:tenant))
  end

  private
    def build_default_from_address(address = nil)
      address ||= ENV["SMTP_USER_NAME"]
      email_address_with_name address, "Mortimer Pro"
    end
end
