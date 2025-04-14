class PasswordsMailer < ApplicationMailer
  def reset(user)
    @resource = user
    mail to: user.email,
      subject: "Reset your password",
      delivery_method: :mailersend,
      delivery_method_options: {
        api_key: ENV["MAILERSEND_API_TOKEN"]
      }

  rescue => e
    UserMailer.error_report(e.to_s, "PasswordsMailer#reset - failed for #{user&.email}").deliver_later
  end
end
