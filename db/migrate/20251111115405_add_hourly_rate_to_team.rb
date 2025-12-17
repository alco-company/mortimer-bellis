class AddHourlyRateToTeam < ActiveRecord::Migration[8.1]
  def up
    add_column :teams, :hourly_rate, :decimal, precision: 11, scale: 2, default: "0.0", null: false
    Team.unscoped.all.each do |team|
      team.update(hourly_rate: "0.0")
    end
  end

  def down
    remove_column :teams, :hourly_rate
  end
end
