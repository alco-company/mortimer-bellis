class Account::Progress < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag

  def view_template
    turbo_frame_tag "progress" do
      div(class: "space-y-2 border-y border-gray-200 p-4") do
        h2(class: "text-lg font-bold") { I18n.t("profile.overview") }
        nav(class: "flex h-35 overflow-y-auto scrollbar-hide", aria_label: "Progress") do
          ol(role: "list", class: "space-y-2") do
            Task.by_tenant.tasked_for_the(Current.user).each do |task|
              render DashboardTask.new task: task, show_options: false, menu: true
            end
          end
        end
      end
    end
  end
end
