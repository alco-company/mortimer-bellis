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

  def show_time_material_quantative(resource:)
    u = resource.unit.blank? ? "" : I18n.t("time_material.units.#{resource.unit}")
    case resource.time.blank?
    when false; "#{ resource.time}t á #{ resource.rate}"
    when true; "%s %s á %s" % [ resource.quantity, u, resource.unit_price ]
    end
  end

  def show_time_material_resource_link(resource:, url: nil, turbo_frame: "form")
    return "" unless resource
    link_to((url || url_for(resource)),
      class: "inline grow flex-nowrap",
      role: "menuitem",
      data: { turbo_action: "advance", turbo_frame: turbo_frame },
      tabindex: "-1") do
      content_tag :span, class: "truncate" do
        resource.name
      end
    end
  end

  def product_display_line_for(time_material)
    time_material.about
  end
end
