class AddDiscardedAtToUserOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :discarded_at, :datetime
    add_index :users, :discarded_at
    add_column :organizations, :discarded_at, :datetime
    add_index :organizations, :discarded_at
  end
end
