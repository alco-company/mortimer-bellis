class PunchCard < ApplicationRecord
  include Accountable
  include SumPunches
  include Datalon

  belongs_to :employee
  has_many :punches, dependent: :destroy

  # scope :values_sum, ->(*keys) {
  #   summands = keys.collect { |k| arel_table[k].sum.as(k.to_s) }
  #   select(*summands)
  # }
  scope :by_name, ->(name) { joins(:employee).where("employees.name LIKE ? or employees.pincode LIKE ? or employees.payroll_employee_ident LIKE ? or employees.job_title LIKE ? or employees.cell_phone LIKE ? or employees.email LIKE ?", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%") if name.present? }
  scope :by_work_date, ->(work_date) { where(work_date: Date.parse(work_date)) if work_date.present? }
  scope :by_work_minutes, ->(work_minutes) { where(work_minutes: work_minutes..) if work_minutes.present? }
  scope :by_break_minutes, ->(break_minutes) { where(break_minutes: break_minutes..) if break_minutes.present? }
  scope :by_ot_minutes, ->(ot_minutes) { where("(ot1_minutes + ot2_minutes) >= #{ot_minutes}") if ot_minutes.present? }
  scope :today, ->(date) { where(work_date: date) }

  # used by eg delete
  def name
    "#{employee.name} #{work_date}"
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_account()
      .by_name(flt["name"])
      .by_work_date(flt["work_date"])
      .by_work_minutes(flt["work_minutes"])
      .by_break_minutes(flt["break_minutes"])
      .by_ot_minutes(flt["ot_minutes"])
  rescue
    filter.destroy if filter
    all
  end

  def self.ordered(resources, field, direction = :desc)
    resources.joins(:employee).order(field => direction)
  end

  def self.form(resource, editable = true)
    PunchCards::Form.new resource, editable: editable
  end

  def ot_minutes
    (ot1_minutes || 0) + (ot2_minutes || 0)
  end

  def breaks
    break_minutes || 0
  end

  def works
    work_minutes || 0
  end

  def first_punch
    punches.order(punched_at: :asc).first.punched_at
  end

  def last_punch
    punches.order(punched_at: :desc).first.punched_at
  end
end
