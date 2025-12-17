class DashboardTask < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  attr_accessor :task, :show_options, :menu

  def initialize(task:, show_options: false, menu: false)
    @task = task
    @show_options = show_options
    @menu = menu
  end

  def view_template
    menu ? menu_task : dashboard_task
  end

  def menu_task
    list_task(task)
    # li do
    #   whitespace
    #   comment { "Current Step" }
    #   whitespace
    #   a(href: "#", class: "flex items-start", aria_current: "step") do
    #     whitespace
    #     span(
    #       class:
    #         "relative flex size-5 shrink-0 items-center justify-center",
    #       aria_hidden: "true"
    #     ) do
    #       whitespace
    #       span(class: "absolute size-4 rounded-full bg-sky-200")
    #       whitespace
    #       span(class: "relative block size-2 rounded-full bg-sky-600")
    #       whitespace
    #     end
    #     whitespace
    #     span(class: "ml-3 text-sm font-medium text-sky-600") do
    #       "Profile information"
    #     end
    #     whitespace
    #   end
    # end
    # li do
    #   whitespace
    #   comment { "Upcoming Step" }
    #   whitespace
    #   a(href: "#", class: "group") do
    #     div(class: "flex items-start") do
    #       div(
    #         class:
    #           "relative flex size-5 shrink-0 items-center justify-center",
    #         aria_hidden: "true"
    #       ) do
    #         div(
    #           class:
    #             "size-2 rounded-full bg-gray-300 group-hover:bg-gray-400"
    #         )
    #       end
    #       p(
    #         class:
    #           "ml-3 text-sm font-medium text-gray-500 group-hover:text-gray-900"
    #       ) { "Theme" }
    #     end
    #     whitespace
    #   end
    # end
  end

  def dashboard_task
    url, help = task&.link&.split(/,| |;/) rescue [ task_url(task), "https://mortimer.pro/help" ]
    help ||= "https://mortimer.pro/help"
    li(id: "task_#{task.id}", class: "overflow-hidden rounded-xl border border-gray-200", data: { controller: "hidden-description" }) do
      div(
        class:
          "flex justify-between items-center gap-x-4 border-b border-slate-100 bg-gray-50 p-2"
      ) do
        url, turbo = url.include?("/") ? [ url, true ] : [ eval(url), false ] rescue [ "#", true ]
        div(class: "flex text-sm/6 text-gray-900") do
          link_to task.title, url, class: "mort-link-primary mr-2 text-sm", data: { turbo_stream: turbo }
          render Icons::Link.new css: "mort-link-primary h-6 "
          context_menu if show_options
        end
        render Icons::ChevronUp.new css: "mort-link-primary h-6 rotate-180 cursor-pointer", data: { action: "click->hidden-description#toggle" }
      end
      dl(class: "-my-3  px-2 py-4 text-sm/6") do
        div(class: "hidden flex justify-between gap-x-4 py-3 text-xs", data: { hidden_description_target: "description" }) { task.description } unless task.description.blank?
        p { link_to t("tasks.dashboard.get_help_here"), help, class: "mort-link-error text-xs" }
        # dt(class: "text-gray-500") { "Last invoice" }
        # dd(class: "text-gray-700") do
        #   time(datetime: "2022-12-13") { "December 13, 2022" }
        # end
        # end
        # div(class: "flex justify-between  self-end gap-x-4 py-3") { link_to t(".start"), task.link, class: "mort-btn-primary" }
        #   dt(class: "text-gray-500") { "Amount" }
        #   dd(class: "flex items-start gap-x-2") do
        #     div(class: "font-medium text-gray-900") { "$2,000.00" }
        #     div(
        #       class:
        #         "rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10"
        #     ) { "Overdue" }
        #   end
        # end
      end
    end
  end

  def context_menu
    div(class: "relative ml-auto") do
      button(
        type: "button",
        class: "-m-2.5 block p-2.5 text-gray-400 hover:text-gray-500",
        id: "options-menu-0-button",
        aria_expanded: "false",
        aria_haspopup: "true"
      ) do
        span(class: "sr-only") { "Open options" }
        svg(
          class: "size-5",
          viewbox: "0 0 20 20",
          fill: "currentColor",
          aria_hidden: "true",
          data_slot: "icon"
        ) do |s|
          s.path(
            d:
              "M3 10a1.5 1.5 0 1 1 3 0 1.5 1.5 0 0 1-3 0ZM8.5 10a1.5 1.5 0 1 1 3 0 1.5 1.5 0 0 1-3 0ZM15.5 8.5a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3Z"
          )
        end
      end
      comment do
        %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
      end
      div(
        class:
          "absolute right-0 z-10 mt-0.5 w-32 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-hidden",
        role: "menu",
        aria_orientation: "vertical",
        aria_labelledby: "options-menu-0-button",
        tabindex: "-1"
      ) do
        comment { %(Active: "bg-gray-50 outline-hidden", Not Active: "") }
        a(
          href: "#",
          class: "block px-3 py-1 text-sm/6 text-gray-900",
          role: "menuitem",
          tabindex: "-1",
          id: "options-menu-0-item-0"
        ) do
          plain "View"
          span(class: "sr-only") { ", Tuple" }
        end
        a(
          href: "#",
          class: "block px-3 py-1 text-sm/6 text-gray-900",
          role: "menuitem",
          tabindex: "-1",
          id: "options-menu-0-item-1"
        ) do
          plain "Edit"
          span(class: "sr-only") { ", Tuple" }
        end
      end
    end
  end

  def list_task(task)
    task.completed? ? completed_task(task) : incomplete_task(task)
  end

  private

  def completed_task(task)
    url, help = task.link.split(/,| |;/) rescue [ task_url(task), "https://mortimer.pro/help" ]
    help ||= "https://mortimer.pro/help"
    url, turbo = url.include?("/") ? [ url, true ] : @_state.user_context[:rails_view_context].send(url)

    li(class: "relative") do
      comment { "Complete Step" }
      link_to(url, class: "relative flex text-sm group", data: { turbo_stream: turbo }) do
        span(class: "flex items-start") do
          span(class: "relative flex size-5 shrink-0 items-center justify-center") do
            svg(class: "size-full text-gray-500 group-hover:text-gray-900",
              viewbox: "0 0 20 20",
              fill: "currentColor",
              aria_hidden: "true",
              data_slot: "icon") do |s|
              s.path(fill_rule: "evenodd",
                d: "M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z",
                clip_rule: "evenodd"
              )
            end
          end
          span(class: "ml-3 flex min-w-0 flex-col") do
            span(class: "text-sm font-medium text-gray-500 group-hover:text-gray-900") { task.name }
          end
        end
      end
    end
  rescue => error
    Rails.logger.error "Error in completed_task: #{error.message}"
    nil
  end

  def incomplete_task(task)
    url, help = task.link.split(/,| |;/) rescue [ task_url(task), "https://mortimer.pro/help" ]
    help ||= "https://mortimer.pro/help"
    url, turbo = url.include?("/") ? [ url, true ] : @_state.user_context[:rails_view_context].send(url)

    li(class: "relative") do
      comment { "Upcoming Step" }
      link_to(url, class: "relative flex text-sm group", data: { turbo_stream: turbo, turbo: turbo }) do
        span(class: "flex items-start") do
          span(class: "ml-0.5 flex h-8 mt-0.5 items-start", aria_hidden: "true") do
            span(class: "relative z-10 flex size-4 items-center justify-center rounded-full border-1 border-gray-300 bg-white group-hover:border-sky-400") do
              span(class: "size-1 rounded-full bg-transparent group-hover:bg-sky-300")
            end
          end
          span(class: "ml-3.5 flex min-w-0 flex-col") do
            span(class: "text-sm font-medium text-gray-500 group-hover:text-sky-400") { task.name }
            span(class: "text-xs text-gray-500 group-hover:text-sky-400") { task.description }
          end
        end
      end
    end
  rescue => error
    Rails.logger.error "Error in incomplete_task: #{error.message}"
    nil
  end
end
