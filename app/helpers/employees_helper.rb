module EmployeesHelper
  def positive_column(val)
    val ?
      "<td class='text-green-500'>\u2713</td>" :
      "<td class=''></td>"
  end

  def employee_mugshot(employee, size: nil, css: "")
    size = size.blank? ? "40x40!" : size
    if (employee.mugshot.attached? rescue false)
      image_tag(url_for(employee.mugshot), class: css)
    else
      # size.gsub!("x", "/") if size =~ /x/
      # size.gsub!("!", "") if size =~ /!/
      image_tag "icons8-customer-64.png", class: css
    end
  rescue
    image_tag "icons8-customer-64.png", class: css
  end

  def link_to_employee_status
    return unless Employee.by_account().count > 0
    link_to t("employees.list.employee_status"), pos_employees_url(api_key: first_employee_token), class: "inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10", target: "_blank", data: { turbo_frame: "_top", turbo_stream: true }
  end

  def link_to_team_employees_status(team)
    return unless Employee.by_account().count > 0
    link_to t("teams.list.employee_status"), pos_employees_url(t: team, api_key: first_employee_token), class: "inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10", target: "_blank", data: { turbo_frame: "_top", turbo_stream: true }
  end

  def first_employee_token
    Employee.by_account().first.access_token
  end
end
