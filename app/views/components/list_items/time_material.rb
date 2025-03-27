class ListItems::TimeMaterial < ListItems::ListItem
  def html_list
    @insufficient_data = resource.has_insufficient_data?
    comment { "bg-green-200 bg-yellow-200" }
    div(id: (dom_id resource), class: "relative flex justify-between gap-x-6 mb-1 px-2 py-5 rounded-xs #{ background }", data: { controller: "time-material" }) do
      div(class: "flex grow min-w-0 gap-x-4", data: time_material_controller?) do
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
      div(class: "flex shrink-0 items-center gap-x-6 ") do
        div(class: "hidden 2xs:flex 2xs:flex-col 2xs:items-end") do
          p(class: "text-sm leading-6 text-gray-900") do
            show_secondary_info
          end
          p(class: "mt-1 text-xs leading-5 text-gray-500 flex items-center") do
            show_time_info
          end
        end
        div(class: "flex-col justify-center") do
          render_context_menu "relative justify-self-center"
        end
      end
      render_play_pause
    end
  end

  def time_material_controller?
    if (resource.user == user or user&.admin? or user&.superadmin?) and (resource.active? or resource.paused?)
      {
        time_material_target: "listlabel",
        reload_url: resource_url(reload: true),
        url: resource_url(pause: (resource.paused? ? "resume" : "pause")),
        action: "click->time-material#toggleActive"
      }
    else
      {
        time_material_target: "listlabel"
      }
    end
  end

  def render_play_pause
    return unless resource.user == user or user&.admin? or user&.superadmin?
    div(class: "absolute inset-0 flex items-center justify-center pointer-events-none") do
      if resource.active? or resource.paused? # and this_user?(resource.user_id)
        resource.paused? ?
          render(Icons::Play.new(cls: "text-gray-500/15 h-1/2 w-1/2 sm:h-22 sm:w-22")) :
          render(Icons::Pause.new(cls: "text-gray-500/15 h-1/2 w-1/2 sm:h-22 sm:w-22"))
        # link_to(resource_url(pause: (resource.paused? ? "resume" : "pause")), data: { turbo_prefetch: "false", turbo_stream: "true" }) do
        # end
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
    return "bg-green-200" if resource.active?
    return "bg-orange-200" if resource.paused?
    return "bg-gray-50" if !resource.pushed_to_erp? and !resource.cannot_be_pushed?
    return "bg-gray-200" if resource.pushed_to_erp?
    return "bg-yellow-400/50" if resource.cannot_be_pushed?
    "bg-gray-50"
  end

  def show_recipient_link
    link_to(resource_url,
      class: "inline grow flex-nowrap truncate",
      role: "menuitem",
      data: { turbo_action: "advance", turbo_frame: "form" },
      tabindex: "-1") do
      name_resource
    end
  end

  def show_matter_link
    mugshot(resource.user, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
    if resource&.user&.global_queries?
      span(class: "hidden md:inline text-xs mr-2 truncate") { show_resource_link(resource.tenant) }
    end
    link_to(edit_resource_url,
      class: " hover:underline truncate",
      data: { turbo_action: "advance", turbo_frame: "form" },
      tabindex: -1) do
      span(class: "2xs:hidden") { show_time_material_quantative unless resource.active? }
      span(class: " truncate") { resource.name }
    end
  end

  def show_secondary_info
    show_time_material_quantative
  end

  def show_time_info
    if resource.active? or resource.paused? # and this_user?(resource.user_id)
      paused_info if resource.paused?
    else
      span(class: "mr-2 truncate") do
        plain (I18n.l(resource.date.to_datetime, format: :date) rescue unsafe_raw(I18n.t("time_material.no_date")))
      end
      if resource.is_invoice?
        span(class: "hidden 2xs:inline-flex w-fit items-center rounded-md bg-green-50 mr-1 px-1 xs:px-2 py-0 xs:py-0.5 text-2xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20 truncate") do
          render Icons::Money.new(cls: "text-green-500 h-4 w-4")
          span(class: "hidden ml-2 md:inline") { I18n.t("time_material.billable") }
        end
      end
      if @insufficient_data
        span(class: "2xs:inline-flex w-fit items-center rounded-md bg-yellow-50 mr-1 px-1 xs:px-2 py-0 xs:py-0.5 text-2xs font-medium text-yellow-700 ring-1 ring-inset ring-yellow-600/20 truncate") do
          render Icons::Warning.new(cls: "text-yellow-500 h-4 w-4")
          span(class: "ml-2 md:inline") { I18n.t("time_material.insufficient_data") }
        end
      end
    end
  end

  def paused_info
    span(class: "flex") do
      plain I18n.l(resource.paused_at.to_datetime, format: :short) rescue ""
    end
  rescue
    {}
  end

  def name_resource
    return resource.customer&.name || resource.customer_name if resource.customer.present? or !resource.customer_name.blank?
    return resource.project&.name || resource.project_name if resource.project.present? or !resource.project_name.blank?
    I18n.t("time_material.internal_or_private")
  rescue
    "!145"
  end

  def show_time_material_quantative
    if resource.active? or resource.paused?
      counter = resource.paused? ? resource.time_spent : (Time.current.to_i - resource.started_at.to_i) + resource.time_spent
      days, hours, minutes, seconds = resource.calc_hrs_minutes counter
      timestring = "%d %02d:%02d:%02d" % [ days, hours, minutes, seconds ]
      span(class: "grow mr-2 time_counter", data: { counter: counter, state: resource.state, time_material_target: "counter" }) { timestring }
    else
      case true
      when (!resource.kilometers.blank? and resource.kilometers != 0); "#{ resource.kilometers}km"
      when resource.quantity.blank?; show_time_details
      else; show_product_details
      end
    end
  rescue
    "!169"
  end

  def show_time_details
    rate = resource.rate.blank? ? product_rates : resource.rate
    "#{ resource.time}t á #{ rate }"
  rescue
    "!176"
  end

  def show_product_details
    u = resource.unit.blank? ? "" : I18n.t("time_material.units.#{resource.unit}")
    "%s %s á %s" % [ resource.quantity, u, resource.unit_price ]
  rescue
    "!183"
  end

  def product_rates
    @product_rates ||= Product
      .where(product_number: [ ps.product_for_time, ps.product_for_overtime, ps.product_for_overtime_100 ])
      .pluck(:base_amount_value)[resource.over_time]
  rescue
    ""
  end

  def ps
    @ps ||= ProvidedService.by_tenant.find_by(name: "Dinero")
  end
end
