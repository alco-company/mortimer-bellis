class Errors::InvalidOtpCodeError < Errors::MortimerError
  def initialize(message = "Invalid OTP code")
    super
  end
end
