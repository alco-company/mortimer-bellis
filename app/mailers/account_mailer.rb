class AccountMailer < ApplicationMailer
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
end
