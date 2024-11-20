class ListItems::Tenant < ListItems::ListItem
  # name
  # email
  # pp_identification
  # locale
  # time_zone
  # created_at
  # updated_at
  # send_state_rrule
  # send_eu_state_rrule
  # color
  # tax_number
  # country
  # access_token


  def show_recipient_link
    link_to tenant_url(resource), data: { turbo_action: "advance", turbo_frame: "form", tabindex: "-1" }, class: "hover:underline" do
      plain resource.name
    end
  end

  def show_left_mugshot
    # mugshot(resource, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain "%s %s " % [ resource.email, resource.time_zone ]
  end
end
