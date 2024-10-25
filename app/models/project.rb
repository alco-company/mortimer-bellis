class Project < ApplicationRecord
  include Tenantable

  belongs_to :customer

  scope :by_fulltext, ->(query) { where("name LIKE :query OR description LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_customer, ->(customer) { where("customer LIKE ?", "%#{customer}%") if customer.present? }
  scope :by_description, ->(description) { where("description LIKE ?", "%#{description}%") if description.present? }
  scope :by_start_date, ->(start_date) { where("start_date LIKE ?", "%#{start_date}%") if start_date.present? }
  scope :by_end_date, ->(end_date) { where("end_date LIKE ?", "%#{end_date}%") if end_date.present? }
  scope :by_state, ->(state) { where("state LIKE ?", "%#{state}%") if state.present? }
  scope :by_budget, ->(budget) { where("budget LIKE ?", "%#{budget}%") if budget.present? }
  scope :by_is_billable, ->(is_billable) { where("is_billable LIKE ?", "%#{is_billable}%") if is_billable.present? }
  scope :by_hourly_rate, ->(hourly_rate) { where("hourly_rate LIKE ?", "%#{hourly_rate}%") if hourly_rate.present? }
  scope :by_priority, ->(priority) { where("priority LIKE ?", "%#{priority}%") if priority.present? }
  scope :by_estimated_minutes, ->(estimated_minutes) { where("estimated_minutes LIKE ?", "%#{estimated_minutes}%") if estimated_minutes.present? }
  scope :by_actual_minutes, ->(actual_minutes) { where("actual_minutes LIKE ?", "%#{actual_minutes}%") if actual_minutes.present? }


  validates :name, presence: true, uniqueness: { scope: :tenant_id, message: I18n.t("locations.errors.messages.name_exist") }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      # .by_customer(flt["customer"])
      .by_name(flt["name"])
      .by_description(flt["description"])
      .by_start_date(flt["start_date"])
      .by_end_date(flt["end_date"])
      .by_state(flt["state"])
      .by_budget(flt["budget"])
      .by_is_billable(flt["is_billable"])
      .by_hourly_rate(flt["hourly_rate"])
      .by_priority(flt["priority"])
      .by_estimated_minutes(flt["estimated_minutes"])
      .by_actual_minutes(flt["actual_minutes"])

  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource:, editable: true)
    Projects::Form.new resource: resource, editable: editable
  end
end
