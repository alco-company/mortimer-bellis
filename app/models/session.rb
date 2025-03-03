class Session < ApplicationRecord
  belongs_to :user
  has_one :tenant, through: :user

  enum :authentication_strategy, { password: 0, entraID: 1, otp: 2 }
end
