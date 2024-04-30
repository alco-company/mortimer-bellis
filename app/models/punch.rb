class Punch < ApplicationRecord
  include Accountable

  belongs_to :employee
  belongs_to :punch_clock, optional: true

  scope :by_name, ->(name) { joins(:employee).where("employees.name LIKE ? or employees.pincode LIKE ? or employees.payroll_employee_ident LIKE ? or employees.job_title LIKE ? or employees.cell_phone LIKE ? or employees.email LIKE ?", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%") if name.present? }
  scope :by_punch_clock, ->(punch_clock) { joins(:punch_clock).where("punch_clocks.name LIKE ?", "%#{punch_clock}%") if punch_clock.present? }
  scope :by_punched_at, ->(punched_at) { where(punched_at: punched_at..) if punched_at.present? }
  scope :by_state, ->(state) { where(state: state) if state.present? }

  def self.filtered(filter)
    flt = filter.filter
    all
      .by_name(flt["name"])
      .by_punch_clock(flt["punch_clock"])
      .by_punched_at(flt["punched_at"])
      .by_state(flt["state"])

    rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Punches::Form.new resource, editable: editable
  end



end
