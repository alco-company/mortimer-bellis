class Errors::MortimerError < StandardError
  def initialize(message = "An error occurred")
    super
  end
end

#   class TwoFactorNotEnabledError < MortimerError
#     def initialize(message = "Two factor not enabled")
#       super
#     end
#   end

#   class UserNotFoundError < MortimerError
#     def initialize(message = "User not found")
#       super
#     end
#   end

#   # class InvalidPasswordConfirmationError < MortimerError
#   #   def initialize(message = "Invalid password confirmation")
#   #     super
#   #   end
#   # end
# end
