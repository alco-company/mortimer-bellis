class TwoFactorAppEnablementForm
  include ActiveModel::Model

  attr_accessor :password, :otp_code
end
