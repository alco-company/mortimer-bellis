class Punch < ApplicationRecord
  include Tenantable
  include Stateable

  belongs_to :user
  belongs_to :punch_clock, optional: true
  belongs_to :punch_card, optional: true

  scope :by_fulltext, ->(q) { joins(:user).where("users.name LIKE :q or users.pincode LIKE :q or users.job_title LIKE :q or users.cell_phone LIKE :q or users.email LIKE :q", q: "%#{q}%") if q.present? }
  scope :by_name, ->(name) { joins(:user).where("users.name LIKE :q or users.pincode LIKE ? or users.job_title LIKE ? or users.cell_phone LIKE ? or users.email LIKE ?", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%") if name.present? }
  scope :by_punch_clock, ->(punch_clock) { joins(:punch_clock).where("punch_clocks.name LIKE ?", "%#{punch_clock}%") if punch_clock.present? }
  scope :by_punched_at, ->(punched_at) { where(punched_at: punched_at..) if punched_at.present? }
  scope :by_payroll_period, ->(payroll_period) { where(punch: payroll_period..) if payroll_period.present? }
  scope :by_state, ->(state) { where(state: state) if state.present? }
  scope :this_week, ->() { where(punched_at: Time.now.beginning_of_week..) }
  scope :sick_absence, ->() { where(state: [ :sick, :iam_sick, :child_sick, :nursing_sick, :lost_work_sick, :p56_sick ]) }

  # used by eg delete
  def name
    "#{user.name} #{punched_at}"
  end

  def self.set_order(resources, field = :created_at, direction = :desc)
    resources.ordered(field, direction)
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_name(flt["name"])
      .by_punch_clock(flt["punch_clock"])
      .by_punched_at(flt["punched_at"])
      .by_state(flt["state"])

  rescue
    filter.destroy if filter
    all
  end

  # def self.ordered(resources, field, direction = :desc)
  #   resources.joins(:user).joins(:punch_clock).order(field => direction)
  # end

  def self.form(resource:, editable: true)
    Punches::Form.new resource: resource, editable: editable
  end
end
