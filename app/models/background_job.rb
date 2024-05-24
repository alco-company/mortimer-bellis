class BackgroundJob < ApplicationRecord
  include Accountable
  include Queueable

  enum :state, {
    in_active:        0,
    un_planned:       1,
    planned:          2,
    running:          3,
    failed:           4,
    finished:         5
  }

  belongs_to :user, optional: true

  scope :by_job_klass, ->(job_klass) { where("job_klass LIKE ? or params LIKE ?", "%#{job_klass}%", "%#{job_klass}%") if job_klass.present? }

  validates :job_klass, presence: true

  def name
    job_klass
  end

  def active?
    !not_active?
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_account()
      .by_job_klass(flt["job_klass"])
  rescue
    filter.destroy if filter
    all
  end

  def self.job_klasses
    [
      ["DatalonPreparationJob","DatalonPreparationJob"],
      ["EmployeeAutoPunchJob","EmployeeAutoPunchJob"],
      ["EmployeeEuStateJob","EmployeeEuStateJob"],
      ["EmployeeStateJob","EmployeeStateJob"],
      ["ImportEmployeesJob","ImportEmployeesJob"],
      ["PunchCardJob","PunchCardJob"],
      ["PunchJob","PunchJob"]
    ]
  end

  def self.form(resource, editable = true)
    BackgroundJobs::Form.new resource, editable: editable
  end
end
