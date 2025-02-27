class PasswordsMailer < ApplicationMailer
  def reset(user)
    @resource = user
    mail subject: "Reset your password", to: user.email
  end
end
