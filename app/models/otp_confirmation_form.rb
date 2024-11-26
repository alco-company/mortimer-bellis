class OtpConfirmationForm
  include ActiveModel::Model

  attr_accessor :otp_code, :button_only
end
