class AddSaltToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :salt, :string, null: false, default: ""
  end
end
