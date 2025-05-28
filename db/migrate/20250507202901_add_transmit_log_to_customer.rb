class AddTransmitLogToCustomer < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :transmit_log, :text
  end
end
