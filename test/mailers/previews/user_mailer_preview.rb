# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/welcome
  def welcome
    user = User.first || User.new(email: "test@example.com", name: "Test")
    UserMailer.with(user: user, params: params).welcome
  end

  def confetti_first_punch
    @user = User.first || User.new(email: "test@example.com", name: "Test")
    @name = @user.name
    @company = @user.tenant.name
    @sender = "info@mortimer.pro"
    UserMailer.with(user: @user, params: params, name: @name, company: @company, sender: @sender).confetti_first_punch
  end

  def user_farewell
    user = User.first || User.new(email: "test@example.com", name: "Test")
    name = user.name || "Test"
    company = user.tenant&.name || "MORTIMER"
    sender = user.tenant&.email || "The Mortimer Team"
    UserMailer.with(user: user, params: params, name: name, company: company, sender: sender).user_farewell
  end

  def last_farewell
    @user = User.first || User.new(email: "test@example.com", name: "Test")
    @name = @user.name
    @company = @user.tenant&.name || "MORTIMER"
    @sender = @user.tenant&.email || "The Mortimer Team"
    UserMailer.with(user: @user, params: params, name: @name, company: @company, sender: @sender).last_farewell
  end

  def info_report
    @info = "Some info"
    @msg = "Some message"
    UserMailer.with(info: @info, params: params, msg: @msg).info_report(@info, @msg)
  end

  def error_report
    @error = "Some error"
    @klass_method = "some_klass_method"
    UserMailer.with(error: @error, params: params, klass_method: @klass_method).error_report(@error, @klass_method)
  end

  def confirmation_instructions
    @user = User.first || User.new(email: "test@example.com", name: "Test")
    @email = @user.email
    @confirmation_url = "/"
    UserMailer.with(user: @user, params: params, email: @email, confirmation_url: @confirmation_url).confirmation_instructions(@user)
  end

  def invitation_instructions
    @resource = User.first || User.new(email: "test@example.com", name: "Test")
    @resource.tenant = Tenant.first || Tenant.new(name: "Test Company", email: "test@example.com")
    @resource.invited_by = User.new(email: "invitee@example.com", name: "Test")
    @invited_by = @resource.invited_by
    @invitation_message = "You have been invited!"
    @accept_url = "/"
    UserMailer.with(resource: @resource, params: params,
      invited_by: @invited_by,
      invitation_message: @invitation_message,
      accept_url: @accept_url).invitation_instructions(@resource, @invited_by, @invitation_message)
  end
end
