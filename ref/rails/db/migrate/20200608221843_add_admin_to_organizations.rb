class AddAdminToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :admin_id, :uuid, references: 'users'
    add_index :organizations, :admin_id
  end
end
