# this service uses dry-rb monads
# however it is not necessary - just my preference
# feel free to return normal values and raise exceptions
#
# this service returns custom errors
# create them if you want to use them
module SecondFactor
  class ProvisionApp
    # include Dry::Monads[:result] # once again we are using dry-rb monads
    # include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    # @param [User] user
    # @param [String] password
    # @param [String] otp_code
    def call(user:, password:, otp_code:)
      User.transaction do
        raise Errors::InvalidPasswordError unless user.valid_password?(password)
        #   return Failure(InvalidPassword.new)
        # end

        raise Errors::TwoFactorAlreadyEnabledError if user.otp_enabled
        #   return Failure(YouAlreadyHaveSecondFactorAppEnabled.new)
        # end

        raise Errors::InvalidOtpCodeError unless user.validate_and_consume_otp!(otp_code)
        #   return Failure(InvalidOtpCode.new)
        # end

        user.otp_required_for_login = true
        user.otp_enabled = true
        user.otp_enabled_at = Time.current
        user.save!

        user
        # Success(user)
      end
    end
  end
end
