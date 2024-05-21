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
      image_tag "icons8-customer-64.png"
    end
  rescue
    image_tag "icons8-customer-64.png"
  end
end
