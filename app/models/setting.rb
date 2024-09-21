class Setting < ApplicationRecord
  include Accountable
  belongs_to :setable, polymorphic: true

  scope :by_key, ->(key) { where("key LIKE ?", "%#{key}%") if key.present? }
  scope :by_priority, ->(priority) { where("priority LIKE ?", "%#{priority}%") if priority.present? }
  scope :by_value, ->(value) { where("value LIKE ?", "%#{value}%") if value.present? }

  validates :key, presence: true, uniqueness: { scope: :account_id, message: I18n.t("settings.errors.messages.key_exist") }
  validates :value, presence: true
  validates :setable_type, presence: true

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_account()
      .by_key(flt["key"])
      .by_priority(flt["priority"])
      .by_value(flt["value"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Settings::Form.new resource, editable: editable, enctype: "multipart/form-data"
  end
end
