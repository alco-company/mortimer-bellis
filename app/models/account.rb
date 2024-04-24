class Account < ApplicationRecord
  has_many :filters, dependent: :destroy

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }

  def self.filtered(filter)
    flt = filter.filter

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
