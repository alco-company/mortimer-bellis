class AddCommentToPunch < ActiveRecord::Migration[8.0]
  def change
    add_column :punches, :comment, :string
  end
end
