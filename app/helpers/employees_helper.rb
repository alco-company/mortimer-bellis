module EmployeesHelper
  def positive_column(val)
    val ?
      "<td class='text-green-500'>\u2713</td>" :
      "<td class=''></td>"
  end
end
