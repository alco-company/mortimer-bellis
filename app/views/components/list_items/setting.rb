class ListItems::Setting < ListItems::ListItem
  # tenant_id
  # setable_type
  # setable_id
  # key
  # priority
  # format
  # value
  # created_at
  # updated_at


  def show_recipient_link
    link_to setting_url(resource), data: { turbo_action: "advance", turbo_frame: "form", tabindex: "-1" }, class: "hover:underline" do
      plain t("settings.keys.#{resource.key}")
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
    plain "%s %s " % [ resource.setable_type, resource.setable_id ]
  end
end
