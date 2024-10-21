module TimeMaterialsHelper
  def show_time_material_customer_link(resource:, url: nil, turbo_frame: "form")
    return "" unless resource
    link_to((url || url_for(resource)),
      class: "inline grow flex-nowrap truncate",
      role: "menuitem",
      data: { turbo_action: "advance", turbo_frame: turbo_frame },
      tabindex: "-1") do
      resource.customer&.name || resource.customer_name rescue "-"
    end
  end
  def show_time_material_resource_link(resource:, url: nil, turbo_frame: "form")
    return "" unless resource
    link_to((url || url_for(resource)),
      class: "inline grow flex-nowrap truncate",
      role: "menuitem",
      data: { turbo_action: "advance", turbo_frame: turbo_frame },
      tabindex: "-1") do
      resource.name
    end
  end

  def product_display_line_for(time_material)
    time_material.about
  end
end
