module Timing
  extend ActiveSupport::Concern

  attr_accessor :hour_time, :minute_time

  included do
    # set time from hour and minute parts
    #
    def set_ptime(ht, mt)
      self.hour_time=ht
      self.minute_time=mt
      self.time
    end

    #
    # return the hour part of the time string (HH:MM)
    #
    def hour_time
      return "" if self.time.blank?
      h, _m = self.time.split(/[:.,]/)
      h || "0"
      # rescue
      #   "0"
    end

    #
    # set the hour part of the time string (HH:MM)
    #
    def hour_time=(val)
      return if val.blank?
      self.time = "%02d:%02d" % [ val.to_i, self.minute_time.to_i ]
    end

    #
    # return the minute part of the time string (HH:MM)
    #
    def minute_time
      return "" if self.time.blank?
      _h, m = self.time.split(/[:.,]/)
      m || "0"
      # rescue
      #   "0"
    end

    #
    # set the minute part of the time string (HH:MM)
    #
    def minute_time=(val)
      return if val.blank?
      self.time = "%02d:%02d" % [ hour_time.to_i, val.to_i ]
    end

    #
    # return a tuple of days, hours, minutes, seconds from a time in seconds
    #
    def calc_hrs_minutes(t)
      days, hours = t.to_i.divmod 86400
      hours, minutes = hours.divmod 3600
      minutes, seconds = minutes.divmod 60
      [ days, hours, minutes, seconds ]
    end

    #
    # return time as a decimal number
    # eg 1:30 => 1.5
    # or 1,50 => 1.5
    # or 1.50 => 1.5
    #
    def calc_time_to_decimal(t = nil)
      t ||= time
      return 0.25 if t.blank? && Current.user.should?(:limit_time_to_quarters)
      return t if t.is_a?(Numeric)
      t = case t
      when Integer, Float; t
      when String
        hr, m = t.split(/[,.:]/)
        (hr = 0.0 && m = 0.0) if hr.blank? && m.blank?
        (hr = hr.to_f && m = 0.0) if m.blank?
        (hr = 0.0 && m = m.to_i.clamp(0, 99)) if hr.blank?
        (m = m.to_i < 10 ? m.to_f / 10 : m.to_f / 100.0)
        (m = m.to_f * 100 / 60.0) if t =~ /:/
        hr.to_f + m
      when NilClass; 0.0
      else 0.0
      end
    rescue
      0.0
    end

    # first make sure time is a number -
    # ie if it's a string with 1.25 or 1,25 or 1:25 reformat it
    # then calculate the hours and minutes from the time integer
    # if the resource should be limited to quarters, then round up the minutes to the nearest quarter
    # finally return the hours and minutes as a string with a colon
    #
    def sanitize_time(ht, mt)
      ptime = set_ptime ht, mt
      t = ptime.split(":")
      minutes = t[0].to_i*60 + t[1].to_i
      hours, minutes = minutes.divmod 60
      if Current.present? && Current.get_user.present? && Current.get_user.should?(:limit_time_to_quarters) # && !ptime.include?(":")
        minutes = case minutes
        when 0; hours == 0 ? 15 : 0
        when 1..15; 15
        when 16..30; 30
        when 31..45; 45
        else hours += 1; 0
        end
      end
      "%02d:%02d" % [ hours.to_i, minutes.to_i ] rescue "00:00"
    end

    #
    # return the number of seconds elapsed in current run (nil if not started)
    #
    def elapsed_seconds_now
      return 0 unless started_at
      minutes_reloaded_at ?
        (Time.current.to_i - minutes_reloaded_at.to_i) :
        (Time.current.to_i - started_at.to_i).clamp(0, 24.hours)
    end

    def add_elapsed_to_registered!(rounding: :round)
      secs = elapsed_seconds_now
      mins =
        case rounding
        when :ceil  then (secs / 60.0).ceil
        when :floor then (secs / 60.0).floor
        else              (secs / 60.0).round
        end
      updates = { registered_minutes: (registered_minutes || 0) + mins, paused_at: nil, time_spent: 0, minutes_reloaded_at: Time.current }
      update!(updates)
      mins
    end

    # Pause current timer, roll current elapsed into registered_minutes and reset the running segment.
    # If stop is true, also mark inactive when possible.
    def pause_time_spent(stop = false)
      add_elapsed_to_registered!
      s = stop ? 3 : 2
      updates = { state: s, paused_at: Time.current, time_spent: 0 }
      update!(updates)
      if stop
        # Try to mark inactive/done if you have states
        # inactive_set = false
        # inactive_set ||= (respond_to?(:inactive!) && !!inactive!) rescue false
        # inactive_set ||= (respond_to?(:archived!) && !!archived!) rescue false
      end
      true
    end

    def resume_time_spent
      update state: 1, minutes_reloaded_at: Time.current, paused_at: nil, time_spent: 0
    end

    def total_seconds(now: Time.current)
      registered_minutes.to_i * 60 + (started_at ? (now - started_at).to_i : 0)
    end

    def add_elapsed_seconds!(seconds)
      mins = (seconds.to_i / 60.0).round
      update!(registered_minutes: registered_minutes.to_i + mins)
    end

    def pause!(at: Time.current, st: "paused")
      minutes_reloaded_at.nil? ?
        update!(minutes_reloaded_at: at, state: st, paused_at: at, registered_minutes: (registered_minutes || 0) + ((at - started_at).to_i / 60)) :
        update!(minutes_reloaded_at: at, state: st, paused_at: at, registered_minutes: (registered_minutes || 0) + ((at - minutes_reloaded_at).to_i / 60))
    end

    def resume!(at: Time.current)
      update!(minutes_reloaded_at: at, paused_at: nil, state: "active")
    end

    def stop!(at: Time.current)
      pause!(at: at, st: "done")
    end
  end

  class_methods do
  end
end
