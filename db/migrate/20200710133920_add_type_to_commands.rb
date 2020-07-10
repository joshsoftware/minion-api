class AddTypeToCommands < ActiveRecord::Migration[6.0]
  def change
    add_column :commands, :type, :string, null: false, default: "external"
  end
end
