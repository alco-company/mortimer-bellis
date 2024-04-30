class ApplicationMailer < ActionMailer::Base
  default from: -> { build_default_from_address }
  layout "mailer"

  private 
    def build_default_from_address
      email_address_with_name ENV["SMTP_USER_NAME"], "Mortimer Pro"
    end

end
