class AddSendTimesToAccount < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :send_state_rrule, :string
    add_column :accounts, :send_eu_state_rrule, :string
  end
end
