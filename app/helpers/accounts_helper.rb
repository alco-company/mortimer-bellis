module AccountsHelper
  def eval_records(assoc)
    case assoc
    when "calendars"
      Calendar.where(calendarable_type: "Team", calendarable_id: @resource.teams.map(&:id))
      .or(Calendar.where(calendarable_type: "Employee", calendarable_id: @resource.employees.map(&:id)))
      .or(Calendar.where(calendarable_type: "Account", calendarable_id: @resource.id))
      .count
    else
      eval("@resource.#{assoc}.count")
    end
  end
end
