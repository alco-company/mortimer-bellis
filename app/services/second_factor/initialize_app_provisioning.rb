# app/services/second_factor/initialize_app_provisioning.rb
#
# this service uses dry-rb monads
# however it is not necessary - just my preference
# feel free to return normal values and raise exceptions
#
# this service returns custom errors
# create them if you want to use them
module SecondFactor
  class InitializeAppProvisioning
    # include Dry::Monads[:result] # <-- We are using dry-rb modnads
    # include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    # @param [User] user
    # @param [String] password
    def call(user:, password:)
      unless user.valid_password?(password)
        raise Errors::InvalidPasswordError.new
        # return Failure(InvalidPassword.new) # <-- instead you could raise
      end

      if user.otp_enabled
        raise Errors::TwoFactorAlreadyEnabledError.new
        # return Failure(YouAlreadyHaveSecondFactorAppEnabled.new) # <-- instead you could raise
      end

      user.otp_secret = User.generate_otp_secret
      user.save!

      user
      # Success(user) # <-- instead just return a value
    end
  end
end
