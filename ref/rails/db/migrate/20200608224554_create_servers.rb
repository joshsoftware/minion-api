class CreateServers < ActiveRecord::Migration[6.0]
  def change
    create_table :servers, id: :uuid do |t|
      t.references :organization
      t.hstore     :config
      t.string     :name
      t.datetime   :last_checkin_at
      t.timestamps
    end
    add_column :servers, :created_by, :uuid, references: 'users'
    add_index :servers, :created_by
  end
end
