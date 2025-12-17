class CustomException < StandardError
  def initialize(code, name, msg, details)
    @code = code
    @name = name
    @details = details
    @msg = msg
    super(msg || "A custom exception has occurred")
  end
end
