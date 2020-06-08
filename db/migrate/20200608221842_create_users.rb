class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :password_digest
      t.references :organization
      t.timestamps
    end
    add_index :users, :email
  end
end
