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
  # product_for_overtime_100


  def show_recipient_link
    p(class: "text-sm/6 font-semibold text-gray-900 dark:text-white") do
      link_to resource_url(), data: { turbo_action: "advance", turbo_frame: "form", tabindex: "-1" }, class: "hover:underline" do
        plain resource.name
      end
      unless resource.authorized?
        span { " - " }
        link_to t("provided_service.authorize_now"), Dinero::Service.new(user: user).auth_url("/provided_services"), class: "mort-link-primary text-sm hover:underline", target: "_top"
        # render partial: "provided_services/#{resource.service.underscore}/authorize", locals: { path: resources_url } unless resource.authorized?
      end
    end
  end

  def show_left_mugshot
    div(class: "flex items-center") do
      input(type: "checkbox", name: "batch[ids][]", value: resource.id, class: "hidden batch mort-form-checkbox mr-2")
      mugshot(resource.authorized_by, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
    end
  end

  def show_matter_mugshot
    mugshot(resource.authorized_by, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain "%s %s " % [ resource.service, resource.organizationID ]
  end
end
