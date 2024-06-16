# require 'terminal-table'

module CronTask
  class Presenter
    def initialize(field_values)
      @field_values = field_values
    end

    def to_s
      rows.collect { |r| r.join "
        "}.to_s
      # Terminal::Table.new do |t|
      #   t.rows = rows
      #   t.style = { border_top: false, border_bottom: false, border_y: '' }
      # end.to_s
    end

    private

    def rows
      # field_names.zip(@field_values.map{ |value| value.join(' ') })
      field_names.zip(@field_values.map { |value| value.join(" ") })
    end

    def field_names
      [
        "minute",
        "hour",
        "day of month",
        "month",
        "day of week",
        "command"
      ]
    end
  end
end
