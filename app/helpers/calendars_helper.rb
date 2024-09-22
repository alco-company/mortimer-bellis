module CalendarsHelper
  def toggle_template_view(params)
    if params[:template].present?
      params[:template]=="off" ? "on" : "off"
    else
      "on"
    end
  end

  def set_links_for_edit_delete(calendar)
    case true
    when request.path.include?("team")
      edit_url = edit_team_calendar_url(calendar.calendarable, calendar)
      delete_url = team_calendar_url(calendar.calendarable, calendar)
    when request.path.include?("employee")
      edit_url = edit_employee_calendar_url(calendar.calendarable, calendar)
      delete_url = employee_calendar_url(calendar.calendarable, calendar)
    when request.path.include?("tenant")
      edit_url = edit_tenant_calendar_url(calendar.calendarable, calendar)
      delete_url = tenant_calendar_url(calendar.calendarable, calendar)
    else
      edit_url = edit_calendar_url(calendar)
      delete_url = calendar_url(calendar)
    end
    [ edit_url, delete_url ]
  end
end
