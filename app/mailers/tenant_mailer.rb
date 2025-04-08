class TenantMailer < ApplicationMailer
  #
  #
  def welcome
    @rcpt =  email_address_with_name params[:tenant].email, params[:tenant].name
    locale = params[:tenant].locale
    @pw = params[:pw]
    @tenant = params[:tenant]
    @resource = @tenant.users.first
    @url = new_users_session_url
    I18n.with_locale(locale) do
      mail to: @rcpt, subject: I18n.t("tenant.mailer.welcome.subject")
    end
  rescue => e
    UserMailer.error_report(e.to_s, "TenantMailer#welcome - failed for #{params[:tenant]&.id}").deliver_later
  end

  def send_invoice
    @tenant = params[:tenant]
    @email = params[:recipient]
    @pdf = params[:invoice_pdf]
    # attachments["invoice.pdf"] = File.read(@pdf)
    mail to: @email, subject: "Mortimer Invoice"
  end

  def send_ambassador_request
    @tenant = params[:tenant]
    @email = params[:recipient]
    mail to: @email, subject: "Mortimer Ambassador Request"
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

    mail to: rcpt, subject: I18n.t("tenant_mailer.datalon_email.subject")
  end

  def report_state
    @tenant = params[:tenant]
    rcpt =  email_address_with_name @tenant.email, @tenant.name
    params[:tmpfiles].each_with_index do |tmpfile, i|
      attachments["report_state_#{i}.pdf"] = File.read(tmpfile)

      # it's a tempfile, so we need to delete it because we reset the finalizer in the ReportingJob
      File.delete tmpfile
    end

    mail to: rcpt, subject: I18n.t("tenant_mailer.report_state.subject")
  end
end
