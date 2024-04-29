class ImportEmployeesJob < ApplicationJob
  queue_as :default

  #
  # args: account, import_file
  #
  def perform(**args)
    super(**args)
    switch_locale do
      importable_employees = CSV.parse(File.read(args[:import_file]), headers: true, col_sep: ";")
      attributes = Employee.new.attributes.keys.reject { |key| key == "id" }
      importable_employees.each do |employee|
        record = Employee.new
        attributes.each do |key|
          record = field(record, employee, key)
        end
        record.account_id = Current.account.id
        record = set_team(record, employee)
        record.save
      end
      File.delete(args[:import_file])
    end
  end

  #
  #
  def field(record, emp, field)
    if field == "pincode"
      record[field] = Employee.next_pincode(emp[field])
    else
      record[field] = emp[field].present? ? emp[field] : nil
    end
    record
  end

  def set_team(record, emp)
    emp["team"] = "empty" if emp["team"].blank?
    record.team_id = Team.find_or_create_by(name: emp["team"]).id
    record
  end
end
