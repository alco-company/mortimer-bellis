class Settings::SettingsIndex < ApplicationComponent
  include Phlex::Rails::Helpers::TurboStreamFrom
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::ImageTag

  def initialize(resources_stream: nil, divider: true, params: {}, breadcrumb: true, resource: nil)
    @resources_stream = resources_stream || "settings:resources"
    @divider = divider
    @params = params
    @breadcrumb = breadcrumb
    @resource = resource
  end

  def view_template
    if @params[:tab].present?
      turbo_frame_tag "settings_list" do
        div(id: "list", role: "list", class: "") do
          comment { "Help Box" }
          div(class: "mx-4 mb-6 p-4 bg-blue-50 border border-blue-200 rounded-xl") do
            h2(class: "font-semibold text-sky-700 mb-1") { t("settings.tabs.h2-title") }
            p(class: "text-sm text-sky-700") do
              plain t("settings.tabs.descriptions.#{@params[:tab]}")
            end
          end

          bread_crumb # if @breadcrumb
          show_tab
        end
      end
    else
      show_index
    end
  end

  def show_index
    turbo_stream_from @resources_stream
    # NOTE: Phlex components can't use the Rails partial API (render partial: ...)
    # so we delegate to the Rails view context manually and inject the HTML.
    # Using unsafe_raw since the partial returns already-safe HTML.
    # unsafe_raw render(partial: "application/header", locals: { batch_form: nil, divider: @divider })
    render(partial: "application/header", locals: { tenant: Current.tenant, batch_form: nil, divider: @divider, params: @params, user: Current.user })
    turbo_frame_tag "settings_list" do
      div(id: "list", role: "list", class: "") do
        comment { "Help Box" }
        div(class: "mx-4 mb-6 p-4 bg-blue-50 border border-blue-200 rounded-xl") do
          h2(class: "font-semibold text-sky-700 mb-1") { t("settings.tabs.h2-title") }
          p(class: "text-sm text-sky-700") do
            plain t("settings.tabs.description")
          end
        end

        div(class: "mx-4 my-6 bg-white rounded-xl shadow divide-y divide-gray-200") do
          settings_user_profile
          settings_organization
          # settings_team
        end

        comment { "Settings List" }
        div(class: "mx-4 my-6 bg-white rounded-xl shadow divide-y divide-gray-200") do
          link2tab "/settings?tab=general", "General Settings", "general", Icons::Setting, css: "h-8 w-8 text-sky-600 bg-sky-100"
          link2tab "/settings?tab=time_material", "Time & Material Settings", "time_material", Icons::TimeMaterial, css: "h-8 w-8 text-green-600 bg-green-100"
          link2tab "/settings?tab=customer", "Customer Settings", "customer", Icons::Customer, css: "h-8 w-8 text-purple-600 bg-purple-100"
          link2tab "/settings?tab=project", "Project Settings", "project", Icons::Project, css: "h-8 w-8 text-teal-600 bg-teal-100"
          link2tab "/settings?tab=product", "Product Settings", "product", Icons::Product, css: "h-8 w-8 text-cyan-600 bg-cyan-100"
          link2tab "/settings?tab=team", "Team Settings", "team", Icons::Team, css: "h-8 w-8 text-fuchsia-600 bg-fuchsia-100"
          link2tab "/settings?tab=user", "User Settings", "user", Icons::User, css: "h-8 w-8 text-rose-600 bg-rose-100"
          link2tab "/settings?tab=erp_integration", "ERP Integration", "erp_integration", Icons::Extension, css: "h-8 w-8 text-indigo-600 bg-indigo-100"
          link2tab "/settings?tab=permissions", "Permissions", "permissions", Icons::User, css: "h-8 w-8 text-slate-600 bg-slate-100"
        end
        # dummy DIV for render to respect previous element my-6
        div() do
          br
        end
      end
    end
  end

  def bread_crumb
    div(class: "mx-8 flex items-center space-x-2 mb-4") do
      if @breadcrumb
        a(
          href: "/settings",
          class: "text-sm text-sky-500 hover:text-sky-700"
        ) { t("settings.label") }
      else
        span(class: "text-sm text-gray-400") { t("settings.label") }
      end
      span(class: "text-sm text-gray-400") { " > " }
      span(class: "text-sm font-medium text-gray-900") { @params[:tab].humanize }
    end
  end

  def show_tab
    res = @resource.nil? ? (@params[:tab]&.classify&.constantize rescue nil) : @resource
    div(class: "p-4") do
      case @params[:tab]&.downcase
      when "general";         settings_tab Setting.general_settings
      when "time_material";   settings_tab Setting.time_material_settings(resource: res)
      when "customer";        settings_tab Setting.customer_settings(resource: res)
      when "project";         settings_tab Setting.project_settings(resource: res)
      when "product";         settings_tab Setting.product_settings(resource: res)
      when "team";            settings_tab Setting.team_settings(resource: res)
      when "user";            settings_tab Setting.user_settings(resource: res)
      when "erp_integration"; settings_tab Setting.erp_integration_settings(resource: res)
      when "permissions";     settings_tab Setting.permissions_settings(resource: res)
      end
    end
  end

  def settings_tab(settings)
    div(class: "ml-6 mr-1") do
      div(class: "text-sm/6 pt-6") { t("settings.tabs.descriptions.#{@params[:tab]}") }
      dl(class: "divide-y divide-gray-100") do
        index = 1
        settings.each do |setting|
          case setting.second["type"]
          when "boolean"; true_false setting, index
          when "text";    text_input setting, index
          when "option";  select_input setting, index
          when "color";   color_input setting, index
          end
          index += 1
        end
      end
    end
  end

  def link2tab(href, label, description, icon, css: "text-gray-600 bg-gray-100")
    a(
      href: href,
      data: { turbo_frame: "settings_list", turbo_action: "advance" },
      class: "flex justify-between items-center px-4 py-4 hover:bg-gray-50"
    ) do
      div(class: "flex items-center space-x-3") do
        div(class: " p-2 rounded-md") do
          render icon.new(css: css)
        end
        div do
          p(class: "font-medium text-gray-900") { label }
          p(class: "text-sm text-gray-500") do
            plain description
          end
        end
      end
      svg(
        class: "h-5 w-5 text-gray-400",
        fill: "none",
        viewbox: "0 0 24 24",
        stroke: "currentColor"
      ) do |s|
        s.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: "M9 5l7 7-7 7"
        )
      end
    end
  end

  def settings_user_profile
    a(
      href: "/users/registrations/edit",
      data: { turbo_frame: "form", turbo_action: "advance" },
      class: "flex justify-between items-center px-4 py-4 hover:bg-gray-50"
    ) do
      div(class: "flex items-center space-x-3") do
        div(class: "p-2 rounded-md") do
          user_mugshot(Current.get_user, css: "w-8", size: "32x32!")
        end
        div do
          p(class: "font-medium text-gray-900") { "User Profile" }
          p(class: "text-sm text-gray-500") do
            "Rates, rounding, comments, delegation"
          end
        end
      end
      svg(
        class: "h-5 w-5 text-gray-400",
        fill: "none",
        viewbox: "0 0 24 24",
        stroke: "currentColor"
      ) do |s|
        s.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: "M9 5l7 7-7 7"
        )
      end
    end
  end

  def settings_organization
    a(
      href: "/tenants/#{Current.tenant.id}/edit",
      data: { turbo_action: "advance", turbo_frame: "form" },
      class: "flex justify-between items-center px-4 py-4 hover:bg-gray-50"
    ) do
      div(class: "flex items-center space-x-3") do
        div(class: " p-2 rounded-md") do
          render LogoComponent.new logo: Current.tenant.logo, img_css: "w-8", just_logo: true
        end
        div do
          p(class: "font-medium text-gray-900") { "Organization Settings" }
          p(class: "text-sm text-gray-500") do
            "Manage organization-wide settings"
          end
        end
      end
      svg(
        class: "h-5 w-5 text-gray-400",
        fill: "none",
        viewbox: "0 0 24 24",
        stroke: "currentColor"
      ) do |s|
        s.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: "M9 5l7 7-7 7"
        )
      end
    end
  end

  def get_class_for_setting(setting_object)
    rc = @resource&.class&.name || nil # || setting_object.class.name
    # rc = @params[:tab].classify if @params[:tab].present? && rc == "Setting"
    rc_id = @resource&.id || nil #  setting_object&.id || 0
    [ rc, rc_id ]
  end

  def true_false(setting, index)
    rc, rc_id = get_class_for_setting(setting.second["object"])
    url = setting.second["id"] == "0" ? "/settings?rc=#{rc}&rc_id=#{rc_id}&target=setting_i_#{index}" : "/settings/#{setting.second["object"].id}"
    target = setting.second["id"] == "0" ? "setting_i_#{index}" : dom_id(setting.second["object"])
    div(class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
      dt(class: "text-sm/6 font-medium text-gray-900") { setting.second["object"].label }
      dd(class: "mt-1 flex text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0") do
        span(class: "grow") { setting.second["object"].description }
        span(class: "ml-4 shrink-0") do
            render ToggleButton.new(resource: setting.second["object"],
            label: "toggle",
            value: setting.second["value"],
            target: target,
            url: url,
            action: "click->boolean#toggle",
            attributes: {
              data: {
                setable_type: rc,
                setable_id: rc_id
              }
            }
          )
        end
      end
    end
  end

  def text_input(setting, index)
    rc, rc_id = get_class_for_setting(setting.second["object"])
    url = setting.second["id"] == "0" ? "/settings?target=setting_i_#{index}" : "/settings/#{setting.second["object"].id}"
    target = setting.second["id"] == "0" ? "setting_i_#{index}" : dom_id(setting.second["object"])
    div(class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
      dt(class: "text-sm/6 font-medium text-gray-900") { setting.second["object"].label }
      dd(class: "mt-1 flex text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0") do
        render TextBox.new(
          resource: setting.second["object"],
          value: setting.second["value"],
          target: target,
          url: url,
          state: "show",
          hint: setting.second["object"].description,
          attributes: {
            class: "flex col-span-2 grow",
            data: {
              setable_type: rc,
              setable_id: rc_id
            }
          },
        )
      end
    end
  end

  def select_input(setting, index)
    rc, rc_id = get_class_for_setting(setting.second["object"])
    url = setting.second["id"] == "0" ? "/settings?target=setting_i_#{index}" : "/settings/#{setting.second["object"].id}"
    target = setting.second["id"] == "0" ? "setting_i_#{index}" : dom_id(setting.second["object"])
    div(id: "setting_#{index}", class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
      dt(class: "text-sm/6 font-medium text-gray-900") { setting.second["object"].label }
      dd(class: "mt-1 flex-col text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0") do
        render SelectComponent.new(
          resource: setting.second["object"],
          field: :value,
          hint: setting.second["object"].description,
          collection: setting.second["options"],
          show_label: false,
          prompt: "Select an option",
          field_class: "flex col-span-2 grow",
          label_class: "sr-only",
          value_class: "flex flex-col grow",
          url: url,
          target: target,
          attributes: {
            key: setting.second["key"],
            class: "flex col-span-2 grow",
            data: {
              action: "change->select#change",
              setable_type: rc,
              setable_id: rc_id
            }
          },
          editable: false
        )
      end
    end
  end

  #
  def user_mugshot(user, size: nil, css: "")
    size = size.blank? ? "40x40!" : size
    if (user.mugshot.attached? rescue false)
      image_tag(url_for(user.mugshot), class: css)
    else
      # size.gsub!("x", "/") if size =~ /x/
      # size.gsub!("!", "") if size =~ /!/
      image_tag "icons8-customer-64.png", class: css
    end
  rescue
    image_tag "icons8-customer-64.png", class: css
  end


  def color_input(setting, index)
    div(id: "setting_#{index}", class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
      dt(class: "text-sm/6 font-medium text-gray-900") { "Company Color" }
      dd(class: "mt-1 text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0") do
        fieldset do
          legend(class: "block text-sm/6 font-semibold text-gray-900") do
            "Choose a label color"
          end
          div(class: "mt-6 flex flex-wrap items-center gap-x-3 gap-y-2") do
            # bg-red-500 bg-orange-500 bg-amber-500 bg-yellow-500 bg-lime-500 bg-green-500 bg-emerald-500 bg-teal-500 bg-cyan-500 bg-sky-500 bg-blue-500 bg-indigo-500 bg-violet-500 bg-purple-500 bg-fuchsia-500 bg-pink-500 bg-rose-500 bg-slate-500 bg-gray-500 bg-zinc-500 bg-neutral-500 bg-stone-500
            %w[ red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose slate gray zinc neutral stone ].each do |color|
              div(
                class:
                  "flex rounded-full outline -outline-offset-1 outline-black/10"
              ) do
                input(
                  aria_label: "#{color.capitalize}",
                  type: "radio",
                  name: "color-choice",
                  value: "#{color}",
                  class:
                    "size-8 appearance-none rounded-full bg-#{color}-500 forced-color-adjust-none checked:outline-2 checked:outline-offset-2 checked:outline-#{color}-500 focus-visible:outline-3 focus-visible:outline-offset-3"
                )
              end
            end
          end
        end
      end
    end
  end
end
