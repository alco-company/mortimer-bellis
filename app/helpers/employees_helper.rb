module EmployeesHelper
  def positive_column(val)
    val ?
      "<td class='text-green-500'>\u2713</td>" :
      "<td class=''></td>"
  end

  def link_to_user_status
    return unless User.by_tenant().count > 0
    link_to t("users.list.user_status"), pos_users_url(api_key: first_user_token), class: "inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10", target: "_blank", data: { turbo_frame: "_top", turbo_stream: true }
  end

  def first_user_token
    User.by_tenant().first.pos_token
  end
end
