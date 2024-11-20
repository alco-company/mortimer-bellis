class EmployeeMailer < ApplicationMailer
  helper :users

  def welcome
    @user = params[:user]
    @tenant = @user.tenant
    @url = pos_employee_url(@user, api_key: @user.access_token)
    @sender = params[:sender]
    mail to: @user.email, subject: I18n.t("user_mailer.welcome.subject")
  end

  def pos_link
    @user = params[:user]
    @tenant = @user.tenant
    @url = pos_employee_url(@user, api_key: @user.access_token)
    @sender = params[:sender]
    mail to: @user.email, subject: I18n.t("user_mailer.pos_link.subject")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.report_state.subject
  #
  def report_state
    @tenant = params[:tenant]
    @users = @tenant.users
    mail to: @tenant.email, subject: "employee state this morning"
  end

  def report_eu_state
    @tenant = params[:tenant]
    @users = @tenant.users
    mail to: @tenant.email, subject: "employee EU Work Time Directive state this morning"
  end

  def invite
    @invitation = params[:invitation]
    @url = employee_invitation_url(@invitation, api_key: @invitation.access_token)
    @company = @invitation.tenant.name
    @email = @invitation.address
    @sender = @inviter = params[:sender]
    mail to: @email, subject: I18n.t("user_mailer.invite.subject")
  end

  def confetti_first_punch
    @user = params[:user]
    @name = @user.name
    @company = @user.tenant.name
    @sender = "info@mortimer.pro"
    mail to: @user.email, subject: I18n.t("user_mailer.confetti.subject")
  end
end
