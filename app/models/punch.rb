class Punch < ApplicationRecord
  include Accountable
  include Stateable

  belongs_to :employee
  belongs_to :punch_clock, optional: true
  belongs_to :punch_card, optional: true

  scope :by_name, ->(name) { joins(:employee).where("employees.name LIKE ? or employees.pincode LIKE ? or employees.payroll_employee_ident LIKE ? or employees.job_title LIKE ? or employees.cell_phone LIKE ? or employees.email LIKE ?", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%") if name.present? }
  scope :by_punch_clock, ->(punch_clock) { joins(:punch_clock).where("punch_clocks.name LIKE ?", "%#{punch_clock}%") if punch_clock.present? }
  scope :by_punched_at, ->(punched_at) { where(punched_at: punched_at..) if punched_at.present? }
  scope :by_payroll_period, ->(payroll_period) { where(punch: payroll_period..) if payroll_period.present? }
  scope :by_state, ->(state) { where(state: state) if state.present? }
  scope :this_week, ->() { where(punched_at: Time.now.beginning_of_week..) }
  scope :sick_absence, ->() { where(state: [ :sick, :iam_sick, :child_sick, :nursing_sick, :lost_work_sick, :p56_sick ]) }
  # used by eg delete
  def name
    "#{employee.name} #{punched_at}"
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_account()
      .by_name(flt["name"])
      .by_punch_clock(flt["punch_clock"])
      .by_punched_at(flt["punched_at"])
      .by_state(flt["state"])

    rescue
    filter.destroy if filter
    all
  end

  def self.ordered(resources, field, direction = :desc)
    resources.joins(:employee).joins(:punch_clock).order(field => direction)
  end

  def self.form(resource, editable = true)
    Punches::Form.new resource, editable: editable
  end
end
