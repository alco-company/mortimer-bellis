module LocationsHelper
  def show_resource_link(resource:, url: nil, turbo_frame: "form")
    link_to((url || url_for(resource)),
      class: "block ",
      role: "menuitem",
      data: { turbo_action: "advance", turbo_frame: turbo_frame },
      tabindex: "-1") do
      resource.name
    end
  end
  def edit_resource_link(resource:, url: nil, turbo_frame: "form")
    link_to((url || edit_resource_url(id: resource.id)),
      class: "block px-3 py-1 text-sm leading-6 text-gray-900",
      role: "menuitem",
      data: { turbo_action: "advance", turbo_frame: turbo_frame },
      tabindex: "-1") do
      plain I18n.t(".edit")
      span(class: "sr-only") do
        plain ", "
        plain resource.name rescue ""
      end
    end
  end
end
