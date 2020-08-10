class AddAdministrationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :administration, :boolean, null: false, default: false
  end
end
