INVITATION_STATES = [
  [ "draft",  I18n.t("invitation.draft") ],
  [ "sent",  I18n.t("invitation.sent") ],
  [ "opened",  I18n.t("invitation.opened") ],
  [ "completed",  I18n.t("invitation.completed") ],
  [ "error",  I18n.t("invitation.error") ]
]

class EmployeeInvitation < ApplicationRecord
  include Tenantable

  belongs_to :tenant
  belongs_to :user
  belongs_to :team

  has_secure_token :access_token

  enum :state, {
    draft:               0,
    sent:                1,
    opened:              2,
    completed:           3,
    error:               4
  }

  scope :by_state, ->(state) { where("state = ?", state) if state.present? }
  scope :by_address, ->(address) { where("address LIKE ?", "%#{address}%") if address.present? }

  validates :team, :address, presence: true

  # used by eg destroy
  def name
    address.truncate(20)
  end

  def sender
    user.name
  rescue
    "unknown"
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_state(flt["state"])
      .by_address(flt["address"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource:, editable: true)
    UserInvitations::Form.new resource: resource, editable: editable, enctype: "multipart/form-data"
  end
end
