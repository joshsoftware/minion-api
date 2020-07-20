class AddHeartbeatToServers < ActiveRecord::Migration[6.0]
  def change
    add_column :servers, :heartbeat_at, :datetime
  end
end
