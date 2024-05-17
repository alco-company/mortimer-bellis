module Pos::EmployeeHelper
  def set_border_color(employee)
    employee.get_team_color
  end

  def set_bg_color_on_state(state)
    case state
    when "in"; "bg-green-200"
    when "break"; "bg-yellow-200"
    when /sick/; "bg-lime-200"
    when /free/; "bg-sky-200"
    end
  end

  def display_public(name)
    name
  end

  def display_short_work_date(obj)
    return "-" if obj.blank? || obj.last_punched_at.nil?
    I18n.l(obj.last_punched_at, format: :dm)
  rescue
    "-"
  end

  def display_todays_work(employee)
    "%s" % display_hours_minutes(employee.minutes_today_up_to_now[:work])
  rescue
    "0"
  end

  def display_todays_break(employee)
    "(%s)" % display_hours_minutes(employee.minutes_today_up_to_now[:break])
  rescue
    "(0)"
  end
end
