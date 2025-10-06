class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #   en.user_mailer.welcome.body
  #
  def welcome
    @rcpt = params[:user].email
    switch_locale do
      mail(
        to: "monitor@alco.dk",
        subject: I18n.t("user_mailer.welcome.subject"),
        headers: xtra_headers(@rcpt),
        delivery_method: :mailersend,
        delivery_method_options: {
          api_key: ENV["MAILERSEND_API_TOKEN"]
        }
      )
      # User.where(role: "admin").each do |admin|
      #   mail to: admin.email, subject: I18n.t("user_mailer.welcome.new_user")
      # end
    end
  rescue => e
    UserMailer.error_report(e.to_s, "UserMailer#welcome - failed for #{params[:user]&.email}").deliver_later
  end

  def confirmation_instructions(user)
    @user = user
    @email = user.email
    @confirmation_url = confirm_users_confirmations_url(token: @user.confirmation_token)

    mail(
      to: @user.email,
      subject: "Confirm your account",
      headers: xtra_headers(@user.email),
      delivery_method: :mailersend,
      delivery_method_options: {
        api_key: ENV["MAILERSEND_API_TOKEN"]
      }
    )
  end

  def invitation_instructions(invitee, invited_by, invitation_message)
    @resource = invitee
    @invited_by = invited_by
    @invitation_message = invitation_message
    @accept_url = users_invitations_accept_url(token: invitee.invitation_token)
    mail to: invitee.email,
      subject: I18n.t("devise.mailer.invitation_instructions.subject"),
      headers: xtra_headers(invitee.email),
      delivery_method: :mailersend,
      delivery_method_options: {
        api_key: ENV["MAILERSEND_API_TOKEN"]
      }

  rescue => e
    UserMailer.error_report(e.to_s, "UserMailer#invitation_instructions - failed for #{invitee&.email}").deliver_later
  end

  def confetti_first_punch
    @user = params[:user]
    @name = @user.name
    @company = @user.tenant.name
    @sender = "info@mortimer.pro"
    mail to: @user.email,
      subject: I18n.t("user_mailer.confetti.subject"),
      headers: xtra_headers(@user.email),
      delivery_method: :mailersend,
      delivery_method_options: {
        api_key: ENV["MAILERSEND_API_TOKEN"]
      }

  rescue => e
    UserMailer.error_report(e.to_s, "UserMailer#confetti_first_punch - failed for #{params[:user]&.email}").deliver_later
  end

  # a user has been removed
  #
  def user_farewell
    @user = params[:user]
    @name = @user.name
    @company = @user.tenant.name
    @sender = @user.tenant.email
    mail to: @user.email,
      subject: I18n.t("user_mailer.user_farewell.subject"),
      headers: xtra_headers(@user.email),
      delivery_method: :mailersend,
      delivery_method_options: {
        api_key: ENV["MAILERSEND_API_TOKEN"]
      }

  rescue => e
    UserMailer.error_report(e.to_s, "UserMailer#user_farewell - failed for #{params[:user]&.email}").deliver_later
  end

  def last_farewell
    @user = params[:user]
    @name = @user.name
    @company = @user.tenant.name
    @sender = "info@mortimer.pro"
    mail to: @user.email,
      subject: I18n.t("user_mailer.farewell.subject"),
      delivery_method: :mailersend,
      delivery_method_options: {
        api_key: ENV["MAILERSEND_API_TOKEN"]
      }

  rescue => e
    UserMailer.error_report(e.to_s, "UserMailer#last_farewell - failed for #{params[:user]&.email}").deliver_later
  end

  def info_report(info, msg)
    @info = info
    @msg = msg
    mail to: "monitor@alco.dk",
      subject: "Info Report",
      delivery_method: :mailersend,
      delivery_method_options: {
        api_key: ENV["MAILERSEND_API_TOKEN"]
      }

  rescue => e
    Rails.logger.error "%s: %s" % [ "UserMailer#info_report - failed for #{info} on #{msg}", e.to_s ]
  end

  def error_report(error, klass_method)
    @error = error
    @klass_method = klass_method
    mail to: "monitor@alco.dk",
      subject: "Error Report",
      delivery_method: :mailersend,
      delivery_method_options: {
        api_key: ENV["MAILERSEND_API_TOKEN"]
      }

  rescue => e
    Rails.logger.error "%s: %s" % [ "UserMailer#error_report - failed for #{error} on #{klass_method}", e.to_s ]
  end

  def xtra_headers(email)
    {
      "List-Unsubscribe" => "<mailto:unsubscribe@mortimer.pro>, <https://mortimer.pro/unsubscribe?u=#{email}>",
      "List-Unsubscribe-Post" => "List-Unsubscribe=One-Click"
    }
  end
end
