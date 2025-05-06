class AddBaseAmountValueToCustomer < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :hourly_rate, :decimal, precision: 11, scale: 2, default: 0.0, null: false
  end
end
