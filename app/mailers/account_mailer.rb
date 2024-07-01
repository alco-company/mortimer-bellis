class AccountMailer < ApplicationMailer
  #
  #
  def welcome
    @rcpt =  email_address_with_name params[:account].email, params[:account].name
    locale = params[:account].locale
    @pw = params[:pw]
    @account = params[:account]
    @resource = @account.users.first
    @url = new_user_session_url
    I18n.with_locale(locale) do
      mail to: @rcpt, subject: I18n.t("account.mailer.welcome.subject")
    end
  end


  # params:
  # :rcpt is the recipient (object) that has two methods: email, and :name
  # :tmpfiles is an array of (temporary) file(s) containing the lon data
  #
  def lon_email
    rcpt =  email_address_with_name params[:rcpt].email, params[:rcpt].name
    params[:tmpfiles].each_with_index do |tmpfile, i|
      attachments["datalon_#{i}.csv"] = File.read(tmpfile)

      # it's a tempfile, so we need to delete it because we reset the finalizer in the ReportingJob
      File.delete tmpfile
    end

    mail to: rcpt, subject: I18n.t("account_mailer.datalon_email.subject")
  end

  def report_state
    Current.account = params[:account]
    rcpt =  email_address_with_name Current.account.email, Current.account.name
    params[:tmpfiles].each_with_index do |tmpfile, i|
      attachments["report_state_#{i}.pdf"] = File.read(tmpfile)

      # it's a tempfile, so we need to delete it because we reset the finalizer in the ReportingJob
      File.delete tmpfile
    end

    mail to: rcpt, subject: I18n.t("account_mailer.report_state.subject")
  end
end
