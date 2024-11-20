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
    Current.user=params[:user]
    switch_locale do
      mail to: "walther@alco.dk", subject: I18n.t("user_mailer.welcome.subject")
      # User.where(role: "admin").each do |admin|
      #   mail to: admin.email, subject: I18n.t("user_mailer.welcome.new_user")
      # end
    end
  end

  def confetti_first_punch
    @user = params[:user]
    @name = @user.name
    @company = @user.tenant.name
    @sender = "info@mortimer.pro"
    mail to: @user.email, subject: I18n.t("user_mailer.confetti.subject")
  end

  def error_report(error, klass_method)
    @error = error
    @klass_method = klass_method
    mail to: "walther@alco.dk", subject: "Error Report"
  end
end
