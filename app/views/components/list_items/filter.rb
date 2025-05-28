class ListItems::Filter < ListItems::ListItem
  # tenant_id
  # name
  # color

  def show_left_mugshot
    div(class: "flex items-center") do
      input(type: "checkbox", name: "batch[ids][]", value: resource.id, class: "hidden batch mort-form-checkbox mr-2")
      # mugshot(resource.user, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
    end
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain "%s " % [ resource.filter.length ]
  end

  def show_recipient_link
    link_to(resource_url,
      class: "inline grow flex-nowrap truncate",
      role: "menuitem",
      data: { turbo_action: "advance", turbo_frame: "form" },
      tabindex: "-1") do
      resource.view
    end
  end

  def show_matter_link
    mugshot(resource.user, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
    if resource&.user&.global_queries?
      span(class: "hidden md:inline text-xs mr-2 truncate") { show_resource_link(resource.tenant) }
    end
    span(class: "md:inline text-xs truncate") do
      link_to(edit_resource_url,
        class: "truncate hover:underline inline grow flex-nowrap",
        data: { turbo_action: "advance", turbo_frame: "form" },
        tabindex: -1) do
        span(class: " truncate") { resource.view }
      end
    end
  end
end
