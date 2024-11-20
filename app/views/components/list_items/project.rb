class ListItems::Project < ListItems::ListItem
  # name
  # tenant_id
  # customer_id
  # description
  # start_date
  # end_date
  # state
  # budget
  # is_billable
  # is_separate_invoice
  # hourly_rate
  # priority
  # estimated_minutes
  # actual_minutes

  def show_recipient_link
    link_to(resource_url,
      class: "truncate hover:underline",
      data: { turbo_action: "advance", turbo_frame: "form" },
      tabindex: -1) do
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
    plain "%s %s " % [ resource.customer&.name, resource.state ]
  end
end
