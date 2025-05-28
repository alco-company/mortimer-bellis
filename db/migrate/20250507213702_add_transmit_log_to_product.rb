class AddTransmitLogToProduct < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :transmit_log, :text
  end
end
