class AddOrganizationToServer < ActiveRecord::Migration[6.0]
  def change
    add_reference :servers, :organization, type: :uuid, index: true
    add_column :servers, :discarded_at, :datetime
    add_index :servers, :discarded_at
  end
end
