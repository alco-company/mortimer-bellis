class PasswordsMailer < ApplicationMailer
  def reset(user)
    @resource = user
    mail to: user.email,
      subject: I18n.t("user_mailer.reset_password_instructions.subject"),
      headers: xtra_headers(@resource)

  rescue => e
    UserMailer.error_report(e.to_s, "PasswordsMailer#reset - failed for #{user&.email}").deliver_later
  end


  def xtra_headers(user)
    token = user.present? && user.respond_to?(:pos_token) ? user.pos_token : "no-token"
    {
      "List-Unsubscribe" => "<mailto:unsubscribe@mortimer.pro>, <https://app.mortimer.pro/unsubscribe?user_token=#{token}>",
      "List-Unsubscribe-Post" => "List-Unsubscribe=One-Click"
    }
  end
end
