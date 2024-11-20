require "csv"
class ImportEmployeesJob < ApplicationJob
  queue_as :default

  #
  # args: tenant, import_file
  #
  def perform(**args)
    super(**args)
    switch_locale do
      importable_users = CSV.parse(File.read(args[:import_file]), headers: true, col_sep: ";")
      attributes = User.new.attributes.keys.reject { |key| %( id, access_token, state ).include? key }
      importable_users.each do |user|
        begin
          record = User.new state: :out
          attributes.each do |key|
            record = field(record, user, key)
          end
          record.tenant_id = Current.tenant.id
          record = set_team(record, user)
          record.save
          UserMailer.with(user: record).welcome.deliver_later
        rescue => exception
          say "ImportUsersJob reached an error on: #{exception.message}"
          say "user: #{user}"
        end
      end
      File.delete(args[:import_file])
    end
  end

  #
  #
  def field(record, emp, field)
    case field
    when "pincode"; record[field] = User.next_pincode(emp[field])
    when "payroll_user_ident"; record[field] = User.next_payroll_user_ident(emp[field])
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
