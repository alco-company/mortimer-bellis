class Settings::SettingsIndex < ApplicationComponent
  include Phlex::Rails::Helpers::TurboStreamFrom
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::DOMID

  def initialize(resources_stream: nil, divider: true, params: {})
    @resources_stream = resources_stream || "settings:resources"
    @divider = divider
    @params = params
  end

  def view_template
    if @params[:tab].present?
      turbo_frame_tag "settings_list" do
        bread_crumb
        show_tab
      end
    else
      show_index
    end
  end

  def show_index
    turbo_stream_from @resources_stream
    render partial: "header", locals: { batch_form: form, divider: @divider }
    turbo_frame_tag "settings_list" do
      div(id: "list", role: "list", class: "") do
        comment { "Help Box" }
        div(class: "mx-4 mb-6 p-4 bg-blue-50 border border-blue-200 rounded-xl") do
          h2(class: "font-semibold text-sky-700 mb-1") { "Need help?" }
          p(class: "text-sm text-sky-700") do
            "Adjust how your time and material tracking works. Your changes apply to all users unless otherwise noted."
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
      a(
        href: "/settings",
        class: "text-sm text-gray-500 hover:text-gray-700"
      ) { "Settings" }
      span(class: "text-sm text-gray-400") { ">" }
      span(class: "text-sm font-medium text-gray-900") { @params[:tab].humanize }
    end
  end

  def show_tab
    div(class: "p-4") do
      case @params[:tab]
      when "general";         settings_tab Setting.general_settings
      when "time_material";   settings_tab Setting.time_material_settings
      when "customer";        settings_tab Setting.customer_settings
      when "project";         settings_tab Setting.project_settings
      when "product";         settings_tab Setting.product_settings
      when "team";            settings_tab Setting.team_settings
      when "user";            settings_tab Setting.user_settings
      when "erp_integration"; settings_tab Setting.erp_integration_settings
      when "permissions";     settings_tab Setting.permissions_settings
      end
    end
  end

  def settings_tab(settings)
    div(class: "ml-6 mr-1") do
      div(class: "text-sm/6 pt-6") { "Settings for organization, team, or user - choose wisely in some situations" }
      dl(class: "divide-y divide-gray-100") do
        index = 1
        settings.each do |setting|
          case setting.second["type"]
          when "boolean"; true_false setting, index
          when "text";    text_input setting, index
          when "select";  select_input setting, index
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
          helpers.user_mugshot(Current.get_user, css: "w-8", size: "32x32!")
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

  def true_false(setting, index)
    url = setting.second["id"] == "0" ? "/settings?target=setting_i_#{index}" : "/settings/#{setting.second["object"].id}"
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
            attributes: {}
          )
        end
      end
    end
  end

  def text_input(setting, index)
    url = setting.second["id"] == "0" ? "/settings?target=setting_i_#{index}" : "/settings/#{setting.second["object"].id}"
    target = setting.second["id"] == "0" ? "setting_i_#{index}" : dom_id(setting.second["object"])

    div(class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
      dt(class: "text-sm/6 font-medium text-gray-900") do
        setting.second["object"].label
      end
      dd(
        class: "mt-1 flex text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0"
      ) do
        render TextBox.new(
          resource: setting.second["object"],
          value: setting.second["value"],
          target: target,
          url: url,
          state: "show",
          hint: setting.second["object"].description,
          attributes: { class: "flex col-span-2 grow" },
        )
      end
    end
  end
  def select_input(setting, index)
    div(id: "setting_#{index}", class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
      dt(class: "text-sm/6 font-medium text-gray-900") { setting.second["object"].label }
      dd(class: "mt-1 flex-col text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0") do
      end
    end
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
