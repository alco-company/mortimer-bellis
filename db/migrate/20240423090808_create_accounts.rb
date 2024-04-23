class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :email
      t.string :pp_identification
      t.string :locale
      t.string :time_zone

      t.timestamps
    end
  end
end
