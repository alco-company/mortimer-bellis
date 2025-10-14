# Preview all emails at http://localhost:3000/rails/mailers/tenant_mailer
class PasswordsMailerPreview < ActionMailer::Preview
  def reset
    @tenant = Tenant.first || Tenant.new(email: "test@example.com", name: "Test Tenant")
    @rcpt = ActionMailer::Base.email_address_with_name @tenant.email, @tenant.name
    @resource = @tenant.users.first || User.new(email: "test@example.com", name: "Test")
    PasswordsMailer.with(tenant: @tenant, params: params, rcpt: @rcpt).reset(@resource)
  end
end
