class Account::Progress < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag

  def view_template
    turbo_frame_tag "progress" do
      div(class: "relative flex h-full flex-col overflow-hidden rounded-[calc(var(--radius-lg)+1px)] p-6") do
        if Current.get_user.tasks.uncompleted.any?
          h3(class: "text-lg font-bold text-sky-700 mb-2") { I18n.t("profile.open_tasks") }
          nav(class: "flex h-35 overflow-y-auto scrollbar-hide", aria_label: "Progress") do
            ol(role: "list", class: "text-slate-700 space-y-2") do
              Task.by_tenant.tasked_for_the(Current.user).each do |task|
                render DashboardTask.new task: task, show_options: false, menu: true
              end
            end
          end
        else
          h3(class: "text-lg font-bold text-sky-700 mb-2") { I18n.t("profile.no_tasks") }
          p(class: "text-slate-500") { I18n.t("profile.no_tasks_message") }
        end
      end
    end
  end
end
