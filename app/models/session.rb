class Session < ApplicationRecord
  belongs_to :user
  has_one :tenant, through: :user

  # mortimer_scoped - override on tables with other tenant scoping association
  scope :mortimer_scoped, ->(ids) { unscoped.where(user_id: ids) } # effectively returns no records

  def self.scoped_for_tenant(id = 1)
    ids = User.where(tenant_id: id).pluck(:id)
    mortimer_scoped(ids)
  end

  enum :authentication_strategy, { password: 0, entraID: 1, otp: 2 }
end
