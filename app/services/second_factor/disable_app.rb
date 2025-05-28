# this service uses dry-rb monads
# however it is not necessary - just my preference
# feel free to return normal values and raise exceptions
#
# this service returns custom errors
# create them if you want to use them
module SecondFactor
  class DisableApp
    # include Dry::Monads[:result]
    # include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    # @param [User] user
    # @param [String] otp_code
    def call(user:, otp_code:)
      User.transaction do
        raise Errors::InvalidOtpCodeError unless user.validate_and_consume_otp!(otp_code)
        #   return Failure(InvalidOtpCodeOrBackupCode.new)
        # end

        user.otp_enabled = false
        user.otp_enabled_at = nil

        user.otp_secret = User.generate_otp_secret
        user.otp_required_for_login = false

        user.save!

        user
        # Success(user)
      end
    end
  end
end
