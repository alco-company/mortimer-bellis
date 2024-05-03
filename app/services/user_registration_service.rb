class UserRegistrationService
  def self.call(user)
    if user.persisted?
      UserMailer.with(user: user).welcome.deliver_now
    end
  end
end
