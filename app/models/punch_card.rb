class PunchCard < ApplicationRecord
  include Tenantable
  include SumPunches
  include Datalon

  belongs_to :user
  has_many :punches, dependent: :destroy

  # scope :values_sum, ->(*keys) {
  #   summands = keys.collect { |k| arel_table[k].sum.as(k.to_s) }
  #   select(*summands)
  # }
  scope :by_fulltext, ->(query) { joins(:user).where("users.name LIKE :query or users.pincode LIKE :query or users.job_title LIKE :query or users.cell_phone LIKE :query or users.email LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_name, ->(name) { joins(:user).where("users.name LIKE ? or users.pincode LIKE ? or users.job_title LIKE ? or users.cell_phone LIKE ? or users.email LIKE ?", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%") if name.present? }
  scope :by_work_date, ->(work_date) { where(work_date: Date.parse(work_date)) if work_date.present? }
  scope :by_work_minutes, ->(work_minutes) { where(work_minutes: work_minutes..) if work_minutes.present? }
  scope :by_break_minutes, ->(break_minutes) { where(break_minutes: break_minutes..) if break_minutes.present? }
  scope :by_ot_minutes, ->(ot_minutes) { where("(ot1_minutes + ot2_minutes) >= #{ot_minutes}") if ot_minutes.present? }
  scope :today, ->(date) { where(work_date: date) }
  scope :this_week, ->() { where(work_date: Time.now.beginning_of_week..) }
  scope :windowed, ->(window) { where(work_date: window[:from]..window[:to]) }

  # used by eg delete
  def name
    "#{user.name} #{work_date}"
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_name(flt["name"])
      .by_work_date(flt["work_date"])
      .by_work_minutes(flt["work_minutes"])
      .by_break_minutes(flt["break_minutes"])
      .by_ot_minutes(flt["ot_minutes"])
  rescue
    filter.destroy if filter
    all
  end

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      "user_id"
      # "work_minutes",
      # "ot1_minutes",
      # "ot2_minutes",
      # "break_minutes",
      # "work_date",
      # "punches_settled_at",
      # "created_at",
      # "updated_at"
    ]
    f = f - [
      "work_date",
      "punches_settled_at",
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  def self.associations
    [ [], [ Punch ] ]
  end

  def self.user_scope(scope)
    case scope
    when "all"; all.by_tenant()
    when "mine"; where(user_id: Current.user.id)
    when "my_team"; where(user_id: Current.user.team.users.pluck(:id))
    end
  end

  def self.named_scope(scope)
    users = User.where name: "%#{scope}%"
    team_users = User.where team_id: Team.where_op(:matches, name: "%#{scope}%").pluck(:id)
    users = users + team_users if team_users.any?
    where(user_id: users.pluck(:id))
  end

  # def self.ordered(resources, field, direction = :desc)
  #   resources.joins(:user).order(field => direction)
  # end

  def self.form(resource:, editable: true)
    PunchCards::Form.new resource: resource, editable: editable
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
