class PasswordsMailer < ApplicationMailer
  def reset(user)
    @resource = user
    mail subject: "Reset your password", to: user.email
  rescue => e
    UserMailer.error_report(e.to_s, "PasswordsMailer#reset - failed for #{user&.email}").deliver_later
  end
end
