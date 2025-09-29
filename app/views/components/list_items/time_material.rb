class ListItems::TimeMaterial < ListItems::ListItem
  def html_list
    @insufficient_data = resource.has_insufficient_data?
    comment { "bg-green-200 bg-yellow-200" }
    div(id: (dom_id resource), class: "list_item group  #{ background } ", data: { list_target: "item", time_material_target: "item", controller: "time-material list-item" }) do
      div(class: "relative flex justify-between gap-x-6 px-4 py-2 group-hover:bg-gray-50 sm:px-6 dark:group-hover:bg-white/2.5 ", data: time_material_controller?) do
        div(class: "flex min-w-0 gap-x-2") do
          show_left_mugshot
          div(class: "min-w-0 flex-auto ") do
            show_recipient_link
            show_matter_link
          end
        end
        div(class: "flex shrink-0 mt-1 items-center") do
          div(class: "flex items-center") do
            div(class: "flex flex-col items-end") do
              div(class: "flex flex-row") do
                show_secondary_info
              end
              p(class: "truncate text-xs/5 text-gray-500 dark:text-gray-400") { show_time_info }
            end
          end
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
        url: resource_url(pause: (resource.paused? ? "resume" : "pause"))
      }
    else
      {
        time_material_target: "listlabel"
      }
    end
  end

  def render_play_pause
    return unless resource.user == user or user&.admin? or user&.superadmin?
    div(class: "place-self-stretch group-hover:bg-gray-50 sm:px-6 dark:group-hover:bg-white/2.5 ") do
      div(class: "flex gap-3 mx-8 py-2", data: { action: "click->time-material#changeState"  }) do
        button(type: "button", data: { icon: "stop" }, class: "icon-stop") do
          render Icons::Stop.new
          plain "Stop"
        end
        div(class: "inline-flex items-center justify-center w-full") { }
        btn = resource.active? ? "pause" : "play"
        # class="icon-play icon-pause"
        button(type: "button", data: { icon: btn }, class: "icon-#{btn}") do
          resource.active? ? render(Icons::Pause.new) : render(Icons::Play.new)
          plain resource.active? ? "Pause" : "Genoptag"
        end
      end
    end if resource.active? or resource.paused?
  end

  def background
    return "bg-green-200" if resource.active?
    return "bg-orange-200" if resource.paused?
    return "bg-gray-50" if !resource.pushed_to_erp? and !resource.cannot_be_pushed?
    # return "bg-gray-200" if resource.pushed_to_erp?
    return "bg-yellow-400/50" if resource.cannot_be_pushed?
    "bg-gray-50"
  end

  def show_recipient_link
    p(class: "text-sm/6 font-semibold text-gray-900 dark:text-white") do
      link_to(resource_url,
        class: "flex",
        role: "menuitem",
        data: { turbo_action: "advance", turbo_frame: "form" },
        tabindex: "-1") do
          # span(class: "absolute inset-x-0 -top-px bottom-0") { }
          span(class: "relative truncate") { name_resource }
        end
    end
  end

  def show_matter_link
    # mugshot(resource.user, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
    div(class: "flex flex-row items-center") do
      render_invoiceable_info
      p(class: "flex text-xs/5 text-gray-500 dark:text-gray-400 truncate") do
        if resource&.user&.global_queries?
          span(class: "hidden md:inline text-xs mr-2 truncate") { show_resource_link(resource: resource.tenant) }
        end
        link_to user.team, data: { turbo_action: "advance", turbo_frame: "form" }, class: "hidden sm:flex relative truncate hover:underline mr-2.5" do
          resource.user.team.name
        end if resource.user.team
        link_to resource.user, data: { turbo_action: "advance", turbo_frame: "form" }, class: "relative truncate hover:underline mr-2.5" do
          resource.user.name
        end if resource.user
        link_to resource, data: { turbo_action: "advance", turbo_frame: "form" }, class: "relative truncate hover:underline mr-2.5" do
          resource.name
        end if resource
      end
    end
  end

  def show_secondary_info
    if resource.active? or resource.paused?
      # p(class: "text-xs xs:text-sm sm:text-lg md:text-2xl font-mono font-bold") { show_time_material_quantative }
      p(class: "text-sm font-medium text-gray-900 dark:text-white") { show_time_material_quantative }
    else
      p(class: "text-sm font-medium text-gray-900 dark:text-white") { show_time_material_quantative }
    end
  end

  def show_time_info
    if resource.active? or resource.paused? # and this_user?(resource.user_id)
      paused_info if resource.paused?
    else
      span(class: "truncate") do
        plain (l(resource.date.to_datetime, format: :date) rescue unsafe_raw(t("time_material.no_date")))
      end
      if @insufficient_data
        span(class: "2xs:inline-flex w-fit items-center rounded-md bg-yellow-50 mr-1 px-1 xs:px-2 py-0 xs:py-0.5 text-2xs font-medium text-yellow-700 ring-1 ring-inset ring-yellow-600/20 truncate") do
          render Icons::Warning.new(css: "text-yellow-500 h-4 w-4")
          span(class: "ml-2 md:inline") { t("time_material.insufficient_data") }
        end
      end
    end
  end

  def paused_info
    span(class: "flex") do
      plain l(resource.paused_at.to_datetime, format: :short) rescue ""
    end
  rescue
    {}
  end

  def render_invoiceable_info
    if resource.is_invoice?
      txt, dot_bgcolor, bgcolor, txtcolor, bordercolor = resource.pushed_to_erp? ? [ "Faktureret", "bg-emerald-600", "bg-emerald-200", "text-emerald-500", "border-emerald-100" ] : [ "Fakturérbar", "bg-emerald-200 animate-pulse", "bg-emerald-500", "text-emerald-100", "border-emerald-600" ]
      div(class: "w-2 h-2 #{dot_bgcolor} rounded-full mx-2 xs:hidden") { }
      span(data_slot: "badge",
        class: "hidden mr-2 xs:inline-flex items-center justify-center rounded-md border px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap shrink-0 [&>svg]:size-3 gap-1 [&>svg]:pointer-events-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive transition-[color,box-shadow] overflow-hidden [a&]:hover:bg-primary/90 #{bgcolor} #{txtcolor} #{bordercolor} shadow-sm") do
        div(class: "w-2 h-2 #{dot_bgcolor} rounded-full mr-2 ")
        plain txt
      end

      # span(class: "hidden 2xs:inline-flex w-fit items-center rounded-md #{color} mr-1 px-1 xs:px-2 py-0 xs:py-0.5 text-2xs font-medium ring-1 ring-inset ring-green-600/20 truncate") do
      #   render Icons::Money.new(css: "#{color} h-4 w-4")
      #   span(class: "hidden ml-2 md:inline") { resource.pushed_to_erp? ? t("time_material.billed") : t("time_material.billable") }
      # end
    end
  end

  def name_resource
    return resource.customer&.name || resource.customer_name if resource.customer.present? or !resource.customer_name.blank?
    return resource.project&.name || resource.project_name if resource.project.present? or !resource.project_name.blank?
    t("time_material.internal_or_private")
  rescue
    "!145"
  end

  def show_time_material_quantative
    if resource.active? or resource.paused?
      # counter = (resource.paused? ? resource.time_spent : (Time.current.to_i - resource.started_at.to_i) + resource.time_spent) * 60
      counter = (resource&.registered_minutes || 0) * 60
      counter += resource.paused? ? 0 : resource.time_spent.to_i
      _days, hours, minutes, seconds = resource.calc_hrs_minutes counter
      timestring = "%02d:%02d:%02d" % [ hours, minutes, seconds ]
      #
      # deferred by sales 25/09/2025
      # if resource.user.should? :limit_time_to_quarters
      #   qhours = hours
      #   qminutes = minutes
      #   qminutes = case minutes
      #   when 0; qhours==0 ? 15 : 0
      #   when 1..15; 15
      #   when 16..30; 30
      #   when 31..45; 45
      #   else; qhours += 1; 0
      #   end
      # end
      # span(class: "text-yellow-700") { "%02d:%02d / " % [ qhours, qminutes ] } if user.should? :limit_time_to_quarters
      #
      span(class: "grow time_counter", data: { counter: counter, state: resource.state, time_material_target: "counter" }) { timestring }
    else
      case true
      when (!resource.kilometers.blank? and resource.kilometers != 0); "#{ resource.kilometers}km"
      when resource.quantity.blank?; show_time_details
      else; show_product_details
      end
    end
  rescue
    "!165"
  end

  def show_time_details
    rate = resource.rate.blank? ? product_rates : resource.rate
    "#{ resource.time}t á #{ rate }"
  rescue
    "!172"
  end

  def show_product_details
    u = resource.unit.blank? ? "" : t("time_material.units.#{resource.unit}")
    "%s %s á %s" % [ resource.quantity, u, resource.unit_price ]
  rescue
    "!179"
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
