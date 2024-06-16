module CronTask
  class TimeLapseInterpreter
    def self.call(interval, field)
      new(interval, field).call
    end

    def initialize(interval, field)
      @interval = interval
      @field = field
    end

    def call
      expanded_set.map(&:to_i)
    end

    private
    attr_reader :interval, :field

    def expanded_set
      if field == "*"
        every_unit_field
      elsif field.include?("/")
        step_field
      elsif field.include?("-")
        range_field
      else
        single_unit_field
      end
    end

    def step_field
      time_units, step = field.split("/")

      if time_units == "*"
        step_values(step)
      else
        min, max = time_units.split("-").map(&:to_i)
        step_values(step).select { |unit| unit >= min && unit <= max }
      end
    end

    def every_unit_field
      interval.to_a
    end

    def range_field
      min, max = field.split("-").map(&:to_i)
      every_unit_field.select { |unit| unit >= min && unit <= max }
    end

    def single_unit_field
      field.split(",").
        select { |unit| unit unless unit.to_i > every_unit_field.sort.last }.
        tap { |units| units << 0 if units.empty? }
    end

    def step_values(step)
      interval.step(step.to_i).to_a
    end
  end
end
