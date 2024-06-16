require "cron_task/time_lapse_interpreter"

module CronTask
  class MappingGenerator
    def initialize(task)
      @task = task
    end

    def call
      crontask_map
        .map { |interval, field| explain(interval, field) }
        .push(unix_command)
    end

    private

    def crontask_map
      field_intervals.values.zip(time_fields)
    end

    def explain(interval, field)
      TimeLapseInterpreter.call(interval, field)
    end

    def field_intervals
      {
        minutes: (0..59),
        hours: (0..23),
        day_of_the_month: (1..31),
        month: (1..12),
        day_of_the_week: (0..6)
      }
    end

    def unix_command
      [ units[5..-1].join(" ") ]
    end

    def time_fields
      units[0..4]
    end

    def units
      @task.split
    end
  end
end
