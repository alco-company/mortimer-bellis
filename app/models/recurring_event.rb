class RecurringEvent < ApplicationRecord
  belongs_to :calendar
  has_many :events

  attr_accessor :schedule

  def recurrence=(value)
    # super(value.to_json)
  end

  # def rule
  #   IceCube::Rule.from_hash(YAML.unsafe_load(recurrence))
  # end

  def schedule
    # @schedule = IceCube::Schedule.from_hash(YAML.unsafe_load(recurrence))
    # schedule = IceCube::Schedule.new
    # schedule.add_recurrence_rule(rule)
    # schedule
  end
end
