class MakeProvidedServiceAuthorizedByNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :provided_services, :authorized_by_id, true
  rescue
    # ignore if already nullable
  end
end
