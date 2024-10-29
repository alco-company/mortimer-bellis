class ListItems::TimeMaterial < ListItems::ListItem
  def view_template
    div(id: (dom_id resource), class: "flex justify-between gap-x-6 mb-1 px-2 py-5 bg-gray-50 #{ background }") do
      div(class: "flex min-w-0 gap-x-4") do
        show_left_mugshot
        div(class: "min-w-0 flex-auto") do
          p(class: "text-sm font-semibold leading-6 text-gray-900 truncate") do
            show_recipient_link
          end
          p(class: "mt-1 flex text-xs leading-5 text-gray-500") do
            show_matter_link
          end
        end
      end
      div(class: "flex shrink-0 items-center gap-x-6") do
        div(class: "hidden 2xs:flex 2xs:flex-col 2xs:items-end") do
          p(class: "text-sm leading-6 text-gray-900") do
            show_secondary_info
          end
          p(class: "mt-1 text-xs leading-5 text-gray-500 flex items-center") do
            show_time_info
          end
        end
        render_context_menu
      end
    end
  end

  # def say_how_much
  #   u = resource.unit.blank? ? "" : unsafe_raw(I18n.t("time_material.responsive_units.#{resource.unit}"))
  #   if resource.quantity.blank?
  #     resource.time.blank? ? "" : span(class: "truncate") { "%s %s" % [ resource.time, u ] }
  #   else
  #     span(class: "truncate") { "%s %s" % [ resource.quantity, u ] }
  #   end
  # end

  def background
    return "bg-gray-50" if !resource.pushed_to_erp? and !resource.cannot_be_pushed?
    return "bg-gray-500/20" if resource.pushed_to_erp?
    return "bg-yellow-400/50" if resource.cannot_be_pushed?
    ""
  end

  def show_recipient_link
    link_to(resource_url,
      class: "inline grow flex-nowrap truncate",
      role: "menuitem",
      data: { turbo_action: "advance", turbo_frame: "form" },
      tabindex: "-1") do
      resource.customer&.name || resource.customer_name rescue "-"
    end
  end

  def show_matter_link
    mugshot(resource.user, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
    if Current.user.global_queries?
      span(class: "hidden md:inline text-xs mr-2") { show_resource_link(resource.tenant) }
    end
    link_to(edit_resource_url,
      class: "truncate hover:underline",
      data: { turbo_action: "advance", turbo_frame: "form" },
      tabindex: -1) do
      span(class: "2xs:hidden") { show_time_material_quantative }
      plain resource.name
    end
  end

  def show_secondary_info
    show_time_material_quantative
  end

  def show_time_info
    if resource.is_invoice?
      span(class: "hidden 2xs:inline-flex w-fit items-center rounded-md bg-green-50 mr-1 px-1 xs:px-2 py-0 xs:py-0.5 text-2xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20 truncate") do
        render Icons::Money.new(cls: "text-green-500 h-4 w-4")
        span(class: "hidden ml-2 md:inline") { I18n.t("time_material.billable") }
      end
    end
    span(class: "truncate") do
      plain I18n.l resource.created_at, format: :date
    end
  end

  def show_time_material_quantative
    u = resource.unit.blank? ? "" : I18n.t("time_material.units.#{resource.unit}")
    case resource.time.blank?
    when false; "#{ resource.time}t á #{ resource.rate}"
    when true; "%s %s á %s" % [ resource.quantity, u, resource.unit_price ]
    end
  end
end
