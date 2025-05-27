class AddBaseAmountValueToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :hourly_rate, :decimal, precision: 11, scale: 2, default: 0.0, null: false
  end
end
