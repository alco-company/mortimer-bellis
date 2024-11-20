#
#
module RRuleEngine
  class RRule
    #
    # validate a rrule string
    # return a RRule object if valid, false otherwise
    #
    # ex: RRULE:FREQ=MONTHLY;BYDAY=+1MO,-1SU;BYSETPOS=-1
    #
    def self.validate(str = "")
      str = str.split(":")[1] if str =~ /^RRULE:/
      rules = str.split(";")
      rules.each do |rule|
        key, value = rule.split("=")
        case key.upcase
        when "FREQ"; validate_string(value, %w[ SECONDLY MINUTELY HOURLY DAILY WEEKLY MONTHLY YEARLY ], "Invalid FREQ value")
        when "UNTIL"; validate_class(value, Time, "Invalid UNTIL value")
        when "COUNT"; validate_range(value, (1..9999), "Invalid COUNT value")
        when "INTERVAL"; validate_range(value, (1..9999), "Invalid INTERVAL value")
        when "BYSECOND"; validate_list(value, (0..59), "Invalid BYSECOND value")
        when "BYMINUTE"; validate_list(value, (0..59), "Invalid BYMINUTE value")
        when "BYHOUR"; validate_list(value, (0..23), "Invalid BYHOUR value")
        when "BYDAY"; validate_by_list(value, [ /([-+]?\d+)?(MO|TU|WE|TH|FR|SA|SU)/, (-5..5) ], "Invalid BYDAY value")
        when "BYMONTHDAY"; validate_by_list(value, [ /([-+]?\d+)/, (-31..31) ], "Invalid BYMONTHDAY value")
        when "BYYEARDAY"; validate_by_list(value, [ /([-+]?\d{1,3})/, (-366..366) ], "Invalid BYYEARDAY value")
        when "BYWEEKNO"; validate_by_list(value, [ /([-+]?\d{1,2})/, (-53..53) ], "Invalid BYWEEKNO value")
        when "BYMONTH"; validate_list(value, (1..12), "Invalid BYMONTH value")
        when "BYSETPOS"; validate_range(value, (-366..366), "Invalid BYSETPOS value")
        when "WKST"; validate_string(value, %w[ MO TU WE TH FRI SA SU ], "Invalid WKST value")
        else raise "Invalid rule key: #{key.upcase}"
        end
      end
      ::RRule.parse(str)
    rescue => e
      say e.message
      false
    end

    def self.say(msg, level = :info)
      Rails.logger.send(level, "-----------------")
      Rails.logger.send(level, msg)
      Rails.logger.send(level, "-----------------")
    end

    def self.validate_string(str, valid, err_msg)
      raise err_msg unless valid.include?(str)
    end

    def self.validate_range(int, valid, err_msg)
      raise err_msg unless valid.include?(int.to_i)
    end

    def self.validate_list(str, valid, err_msg)
      list = str.split(",")
      list.each do |item|
        raise err_msg unless valid.include?(item.to_i)
      end
    end

    #
    # BYDAY=+1MO,+2TU, -13FR
    def self.validate_by_list(str, valid, err_msg)
      re, valid = valid
      matches = str.scan(re)
      raise err_msg unless matches.any?
      matches.each do |item|
        raise err_msg unless valid.include?(item[0].to_i)
      end
    end
  end
end
