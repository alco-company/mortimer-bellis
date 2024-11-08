class ListItems::ProvidedService < ListItems::ListItem
  # tenant_id
  # authorized_by_id
  # name
  # service
  # params
  # created_at
  # updated_at
  # organizationID
  # account_for_one_off
  # product_for_time
  # product_for_overtime


  def show_recipient_link
    link_to resource_url(), data: { turbo_action: "advance", turbo_frame: "form", tabindex: "-1" }, class: "hover:underline" do
      plain resource.name
    end
  end

  def show_left_mugshot
    mugshot(resource.authorized_by, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
  end

  def show_matter_mugshot
    mugshot(resource.authorized_by, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain "%s %s " % [ resource.service, resource.organizationID ]
  end
end
