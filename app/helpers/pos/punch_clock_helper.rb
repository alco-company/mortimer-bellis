module Pos::PunchClockHelper

  def pos_punch_clock_path
    "/pos/punch_clock?api_key=#{@resource.access_token}"
  end

  def pos_punch_clock_edit_path
    "/pos/punch_clock/edit?api_key=#{@resource.access_token}"
  end

  def display_hours_minutes minutes
    return "0m" if minutes.blank?
    return "%dmin" % minutes if (minutes < 60)
    mins = minutes.to_i.divmod(60)
    I18n.t(:hours_minutes, hours: mins[0], minutes: mins[1])    
  end
end
