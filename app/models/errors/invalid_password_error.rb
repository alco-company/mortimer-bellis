class Errors::InvalidPasswordError < Errors::MortimerError
  def initialize(message = "Invalid password")
    super
  end
end
