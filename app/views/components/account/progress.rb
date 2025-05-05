class Account::Progress < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag

  def view_template
    turbo_frame_tag "progress" do
      div(class: "relative flex h-full flex-col overflow-hidden rounded-[calc(var(--radius-lg)+1px)] p-6") do
        h3(class: "text-lg font-bold text-sky-700 mb-2") { I18n.t("profile.overview") }
        nav(class: "flex h-35 overflow-y-auto scrollbar-hide", aria_label: "Progress") do
          ol(role: "list", class: "text-slate-700 space-y-2") do
            Task.by_tenant.tasked_for_the(Current.user).each do |task|
              render DashboardTask.new task: task, show_options: false, menu: true
            end
          end
        end
      end
    end
  end
end
