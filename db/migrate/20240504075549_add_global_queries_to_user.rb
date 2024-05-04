class AddGlobalQueriesToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :global_queries, :boolean, default: false
  end
end
