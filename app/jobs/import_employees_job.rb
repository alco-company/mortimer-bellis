require "csv"
class ImportEmployeesJob < ApplicationJob
  queue_as :default

  #
  # args: tenant, import_file
  #
  def perform(**args)
    super(**args)
    switch_locale do
      importable_employees = CSV.parse(File.read(args[:import_file]), headers: true, col_sep: ";")
      attributes = Employee.new.attributes.keys.reject { |key| %( id, access_token, state ).include? key }
      importable_employees.each do |employee|
        begin
          record = Employee.new state: :out
          attributes.each do |key|
            record = field(record, employee, key)
          end
          record.tenant_id = Current.tenant.id
          record = set_team(record, employee)
          record.save
          EmployeeMailer.with(employee: record).welcome.deliver_later
        rescue => exception
          say "ImportEmployeesJob reached an error on: #{exception.message}"
          say "employee: #{employee}"
        end
      end
      File.delete(args[:import_file])
    end
  end

  #
  #
  def field(record, emp, field)
    case field
    when "pincode"; record[field] = Employee.next_pincode(emp[field])
    when "payroll_employee_ident"; record[field] = Employee.next_payroll_employee_ident(emp[field])
    else
      record[field] = emp[field].present? ? emp[field] : nil
    end
    record
  end

  def set_team(record, emp)
    emp["team"] = "empty" if emp["team"].blank?
    record.team_id = Team.find_or_create_by(tenant: Current.tenant, name: emp["team"]).id
    record
  end
end
