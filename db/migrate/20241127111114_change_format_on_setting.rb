class ChangeFormatOnSetting < ActiveRecord::Migration[8.1]
  def change
    rename_column :settings, :format, :formating
  end
end
