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
    p(class: "text-sm/6 font-semibold text-gray-900 dark:text-white") do
      link_to tenant_url(resource), data: { turbo_action: "advance", turbo_frame: "form", tabindex: "-1" }, class: "hover:underline" do
        plain resource.name
      end
    end
  end

  def show_matter_link
    div(class: "flex flex-row items-center") do
      show_matter_mugshot
      if user&.global_queries? && resource.respond_to?(:tenant)
        span(class: "hidden md:inline text-xs mr-2 truncate ") { show_resource_link(resource: resource.tenant) }
      end unless resource_class == Tenant
      span(class: "md:inline text-xs truncate") do
        resource.time_zone
        # link_to(customer_url(resource&.customer),
        #   class: "truncate hover:underline inline grow flex-nowrap",
        #   data: { turbo_action: "advance", turbo_frame: "form" },
        #   tabindex: -1) do
        #   span(class: "hidden") { show_secondary_info }
        #   plain resource&.customer&.name
        # end
      end
    end
  end

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
    p(class: "text-sm font-medium text-gray-900 dark:text-white") do
      plain resource.email
    end
  end
end
