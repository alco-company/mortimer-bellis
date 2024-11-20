module TenantsHelper
  def eval_records(assoc)
    case assoc
    when "calendars"
      Calendar.where(calendarable_type: "Team", calendarable_id: @resource.teams.map(&:id))
      .or(Calendar.where(calendarable_type: "User", calendarable_id: @resource.users.map(&:id)))
      .or(Calendar.where(calendarable_type: "Tenant", calendarable_id: @resource.id))
      .count
    else
      eval("@resource.#{assoc}.count")
    end
  end
end
