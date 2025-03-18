class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #   en.user_mailer.welcome.body
  #
  def welcome
    # rcpt =  email_address_with_name params[:rcpt].email, params[:rcpt].name
    @rcpt = params[:user].email
    # @rcpt=params[:user]
    switch_locale do
      mail to: "monitor@alco.dk", subject: I18n.t("user_mailer.welcome.subject")
      # User.where(role: "admin").each do |admin|
      #   mail to: admin.email, subject: I18n.t("user_mailer.welcome.new_user")
      # end
    end
  end

  def confirmation_instructions(user)
    @user = user
    @email = user.email
    @confirmation_url = confirm_users_confirmations_url(token: @user.confirmation_token)

    mail(to: @user.email, subject: "Confirm your account")
  end

  def invitation_instructions(invitee, invited_by, invitation_message)
    @resource = invitee
    @invited_by = invited_by
    @invitation_message = invitation_message
    @accept_url = users_invitations_accept_url(token: invitee.invitation_token)
    mail to: invitee.email, subject: I18n.t("devise.mailer.invitation_instructions.subject")
  end


  def confetti_first_punch
    @user = params[:user]
    @name = @user.name
    @company = @user.tenant.name
    @sender = "info@mortimer.pro"
    mail to: @user.email, subject: I18n.t("user_mailer.confetti.subject")
  end

  # a user has been removed
  #
  def user_farewell
    @user = params[:user]
    @name = @user.name
    @company = @user.tenant.name
    @sender = @user.tenant.email
    mail to: @user.email, subject: I18n.t("user_mailer.user_farewell.subject")
  end

  def last_farewell
    @user = params[:user]
    @name = @user.name
    @company = @user.tenant.name
    @sender = "info@mortimer.pro"
    mail to: @user.email, subject: I18n.t("user_mailer.farewell.subject")
  end

  def error_report(error, klass_method)
    @error = error
    @klass_method = klass_method
    mail to: "monitor@alco.dk", subject: "Error Report"
  end
end
