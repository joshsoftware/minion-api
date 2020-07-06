class AddMissingTimestamps < ActiveRecord::Migration[6.0]
  def change
    add_timestamps(:agent_configurations)
    add_timestamps(:commands)
    add_timestamps(:logs)
    add_timestamps(:organizations)
    add_timestamps(:servers)
    add_timestamps(:servers_tags)
    add_timestamps(:telemetries)
    add_timestamps(:tags)
  end
end
