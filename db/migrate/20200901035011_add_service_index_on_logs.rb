class AddServiceIndexOnLogs < ActiveRecord::Migration[6.0]
  def change
    add_index :logs, :service
  end
end
