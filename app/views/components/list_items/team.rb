class ListItems::Team < ListItems::ListItem
  # name
  # color
  # locale
  # time_zone
  # created_at
  # updated_at
  # punches_settled_at
  # payroll_team_ident
  # state
  # description
  # email
  # cell_phone
  # pbx_extension
  # contract_minutes
  # contract_days_per_payroll
  # contract_days_per_week
  # hour_pay
  # ot1_add_hour_pay
  # ot2_add_hour_pay
  # hour_rate_cent
  # ot1_hour_add_cent
  # ot2_hour_add_cent
  # tmp_overtime_allowed
  # eu_state
  # blocked
  # allowed_ot_minutes
  # country

  def show_recipient_link
    link_to team_url(resource), data: { turbo_action: "advance", turbo_frame: "form", tabindex: "-1" }, class: "hover:underline" do
      plain resource.name
    end
  end

  def show_left_mugshot
    input(type: "checkbox", name: "batch[ids][]", value: resource.id, class: "hidden batch mort-form-checkbox mr-2")
    # mugshot(resource, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain "%s %s " % [ resource.locale, resource.time_zone ]
  end
end
