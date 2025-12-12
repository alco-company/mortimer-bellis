class TenantMailer < ApplicationMailer
  after_action :log_email_details

  #
  #
  def welcome
    @rcpt = email_address_with_name params[:tenant].email, params[:tenant].name
    @tenant = params[:tenant]
    @user = @tenant.users.first
    set_locale
    mail to: @rcpt,
      subject: I18n.t("tenant.mailer.welcome.subject"),
      headers: xtra_headers(@user)
    # delivery_method: :mailersend,
    # delivery_method_options: {
    #   api_key: ENV["MAILERSEND_API_TOKEN"]
    # }

  rescue => e
    UserMailer.error_report(e.to_s, "TenantMailer#welcome - failed for #{params[:tenant]&.id}").deliver_later
  end

  def send_invoice
    @tenant = params[:tenant]
    @pdf = params.dig(:invoice_pdf) || nil
    @email = params.dig(:recipient) || @tenant.email
    set_locale
    attachments["invoice.pdf"] = File.read(@pdf) if @pdf.present? && File.exist?(@pdf)
    @user = @tenant.users.first
      mail to: @email,
        subject: "Mortimer Invoice",
        headers: xtra_headers(@user)
    # delivery_method: :mailersend,
    # delivery_method_options: {
    #   api_key: ENV["MAILERSEND_API_TOKEN"]
    # }
  end

  def send_ambassador_request
    @tenant = params[:tenant]
    @email = params[:recipient]
    @user = @tenant.users.first
      mail to: @email,
        subject: "Mortimer Ambassador Request",
        headers: xtra_headers(@user)
    # delivery_method: :mailersend,
    # delivery_method_options: {
    #   api_key: ENV["MAILERSEND_API_TOKEN"]
    # }
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

  def backup_created
    @tenant = params[:tenant]
    @user = @tenant.users.first || @tenant.users.build
    @link = params[:link]
    @pdf_report_url = params[:pdf_report_url]
    @email = params.dig(:recipient) || @tenant.email
    mail to: @email,
      subject: "Tenant Backup Created",
      headers: xtra_headers(@user)
    # delivery_method: :mailersend,
    # delivery_method_options: {
    #   api_key: ENV["MAILERSEND_API_TOKEN"]
    # }
  end

  def restore_completed
    Rails.logger.info "TenantMailer.restore_completed: Starting to build email"
    @tenant = params[:tenant]
    @user = @tenant.users.first || @tenant.users.build
    @archive = params[:archive]
    @pdf_report_url = params[:pdf_report_url]
    @email = params.dig(:recipient) || @tenant.email

    Rails.logger.info "TenantMailer.restore_completed: Tenant=#{@tenant.id} (#{@tenant.name}), Email=#{@email}, Archive=#{@archive}"

    set_locale

    Rails.logger.info "TenantMailer.restore_completed: Calling mail() with to=#{@email}"
    result = mail to: @email,
      subject: "Tenant Backup Restore Completed",
      headers: xtra_headers(@user)

    Rails.logger.info "TenantMailer.restore_completed: mail() completed successfully"
    result
    # delivery_method: :mailersend,
    # delivery_method_options: {
    #   api_key: ENV["MAILERSEND_API_TOKEN"]
    # }
  end

  def xtra_headers(user)
    token = user.present? && user.respond_to?(:pos_token) ? user.pos_token : "no-token"
    {
      "List-Unsubscribe" => "<mailto:unsubscribe@mortimer.pro>, <https://app.mortimer.pro/unsubscribe?user_token=#{token}>",
      "List-Unsubscribe-Post" => "List-Unsubscribe=One-Click"
    }
  end

  private

  def log_email_details
    Rails.logger.info "TenantMailer: Email prepared - Action: #{action_name}, To: #{message.to}, Subject: #{message.subject}"
    Rails.logger.info "TenantMailer: Delivery method: #{message.delivery_method.class.name}"
  end
end
