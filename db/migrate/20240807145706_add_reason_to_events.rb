class AddReasonToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :work_type, :string
    add_column :events, :reason, :string
    add_column :events, :break_minutes, :integer
    add_column :events, :breaks_included, :boolean
  end
end
