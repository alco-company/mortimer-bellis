# Preview all emails at http://localhost:3000/rails/mailers/tenant_mailer
class TenantMailerPreview < ActionMailer::Preview
  def welcome
    @tenant = Tenant.first || Tenant.new(email: "test@example.com", name: "Test Tenant")
    @rcpt = ActionMailer::Base.email_address_with_name @tenant.email, @tenant.name
    @resource = @tenant.users.first || User.new(email: "test@example.com", name: "Test")
    TenantMailer.with(tenant: @tenant, params: params, rcpt: @rcpt).welcome
  end

  def send_invoice
    @tenant = Tenant.first || Tenant.new(email: "test@example.com", name: "Test Tenant")
    TenantMailer.with(tenant: @tenant, params: params).send_invoice
  end

  def send_ambassador_request
    @tenant = Tenant.first || Tenant.new(email: "test@example.com", name: "Test Tenant")
    @email = "test@example.com"
    TenantMailer.with(tenant: @tenant, params: params, email: @email).send_ambassador_request
  end

  def backup_created
    @tenant = Tenant.first || Tenant.new(email: "test@example.com", name: "Test Tenant")
    @rcpt = ActionMailer::Base.email_address_with_name @tenant.email, @tenant.name
    @user = @tenant.users.first || @tenant.users.build
    @link = "http://example.com/backup_link"
    @recipient = params.dig(:recipient) || @tenant
    TenantMailer.with(tenant: @tenant, link: @link, user: @user, params: params, recipient: @recipient).backup_created
  end

  def restore_completed
    @tenant = Tenant.first || Tenant.new(email: "test@example.com", name: "Test Tenant")
    @summary = params[:summary]
    @archive = params[:archive]
    @recipient = params.dig(:recipient) || @tenant
    TenantMailer.with(tenant: @tenant, params: params, summary: @summary, archive: @archive, recipient: @recipient).restore_completed
  end
end
