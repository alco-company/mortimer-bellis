class RemoveUserEmailIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    idxs = connection.indexes(:users)

    # Drop unique single-column email index if present
    if (email_idx = idxs.find { |i| i.columns == [ "email" ] && i.unique })
      remove_index :users, name: email_idx.name
      add_index :users, :email, name: "index_users_on_email" unless index_exists?(:users, :email, name: "index_users_on_email")
    end

    # Drop unique composite (tenant_id, email) if that exists
    if (tenant_email_idx = idxs.find { |i| i.columns.sort == [ "email", "tenant_id" ] && i.unique })
      remove_index :users, name: tenant_email_idx.name
      add_index :users, [ :tenant_id, :email ],
                name: "index_users_on_tenant_id_and_email" unless index_exists?(:users, [ :tenant_id, :email ], name: "index_users_on_tenant_id_and_email")
    end
  end

  def down
    # Recreate unique single email index
    if index_exists?(:users, :email, name: "index_users_on_email")
      remove_index :users, name: "index_users_on_email"
    end
    add_index :users, :email, unique: true, name: "index_users_on_email"

    # Recreate unique composite if tenant_id column exists
    if column_exists?(:users, :tenant_id)
      if index_exists?(:users, [ :tenant_id, :email ], name: "index_users_on_tenant_id_and_email")
        remove_index :users, name: "index_users_on_tenant_id_and_email"
      end
      add_index :users, [ :tenant_id, :email ],
                unique: true,
                name: "index_users_on_tenant_id_and_email"
    end
  end
end
