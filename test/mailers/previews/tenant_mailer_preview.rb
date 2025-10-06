# Preview all emails at http://localhost:3000/rails/mailers/tenant_mailer
class TenantMailerPreview < ActionMailer::Preview
  def welcome
    @tenant = Tenant.first || Tenant.new(email: "test@example.com", name: "Test Tenant")
    @rcpt = ActionMailer::Base.email_address_with_name @tenant.email, @tenant.name
    @locale = @tenant.locale
    @resource = @tenant.users.first || User.new(email: "test@example.com", name: "Test")
    TenantMailer.with(tenant: @tenant, rcpt: @rcpt, locale: @locale, resource: @resource).welcome
  end

  def send_invoice
    @tenant = Tenant.first || Tenant.new(email: "test@example.com", name: "Test Tenant")
    TenantMailer.with(tenant: @tenant).send_invoice
  end

  def send_ambassador_request
    @tenant = Tenant.first || Tenant.new(email: "test@example.com", name: "Test Tenant")
    @email = "test@example.com"
    TenantMailer.with(tenant: @tenant, email: @email).send_ambassador_request
  end
end
