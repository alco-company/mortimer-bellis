class Account::Progress < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  def initialize(priority: -200.., no_tasks_message: t("profile.no_tasks_message"))
    @priority = get_(priority)
    @no_tasks_message = no_tasks_message
  end

  def view_template
    turbo_frame_tag "#{Current.get_user.id}_progress" do
      div(class: "relative flex h-full flex-col overflow-hidden rounded-[calc(var(--radius-lg)+1px)] p-6") do
        div(class: "flex flex-row justify-between") do
          h3(class: "text-lg font-bold text-sky-700 mb-2") { t("profile.open_tasks") }
          link2 url: new_modal_url(modal_form: "new_task", id: nil, resource_class: "task", modal_next_step: "accept", url: new_task_url),
            label: t("tasks.new.title"),
            css: "flex flex-shrink rounded-full bg-sky-700 px-4 py-2 text-2xs text-white hover:bg-sky-800 items-center",
            icon: "add"
        end

        if Current.get_user.tasks.where(priority: @priority).any?
          # if Current.get_user.tasks.uncompleted.any?
          nav(class: "flex h-35 overflow-y-auto scrollbar-hide", aria_label: "Progress") do
            ol(id: "task_list", role: "list", class: "text-slate-700 space-y-2") do
              Task.by_tenant.where(priority: @priority).tasked_for_the(Current.get_user).order(completed_at: :asc).each do |task|
                render DashboardTask.new task: task, show_options: false, menu: true
              end
            end
          end
        else
          p(class: "text-slate-500") { @no_tasks_message }
        end
      end
    end
  end

  private

    def link2(url:, label:, action: nil, data: { turbo_stream: true }, icon: nil, css: "")
      data[:action] = action if action
      link_to url,
        data: data,
        class: css,
        role: "menuitem",
        tabindex: "-1" do
        render_icon icon
        span(class: "text-nowrap pl-2") { label }
        span(class: "sr-only") do
          plain label
          plain " "
          plain resource.name rescue ""
        end
      end if url.present?
    end

    def render_icon(icon)
      return if icon.blank?
      render "Icons::#{icon.camelcase}".constantize.new(css: "h-4 w-4 text-gray-400")
    end

    def get_(priority)
      if Current.get_user.can? :use_tasks
        priority
      else
        -200..-1
      end
    end
end
