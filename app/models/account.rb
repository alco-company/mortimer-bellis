class Account < ApplicationRecord
  has_many :filters, dependent: :destroy

  scope :by_name, ->(name) { here("name LIKE ?", "%#{name}%") if name.present? }

  def self.filtered(filter)
    flt = JSON.parse filter.filter

    all
      .by_name(flt["name"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource)
    Accounts::Form.new resource
  end
end
