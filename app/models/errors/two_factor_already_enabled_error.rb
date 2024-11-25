class Errors::TwoFactorAlreadyEnabledError < Errors::MortimerError
  def initialize(message = "Two factor already enabled")
    super
  end
end
