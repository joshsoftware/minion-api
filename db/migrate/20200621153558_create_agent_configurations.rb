# frozen_string_literal: true

class CreateAgentConfigurations < ActiveRecord::Migration[6.0]
  def change
    create_table :agent_configurations, primary_key: %i[id server_id] do |t|
      t.uuid :id, null: false
      t.uuid :server_id, null: false
      t.json :configuration, null: false, default: '{}'
      t.string :source, null: false, default: 'admin'
      t.integer :version, null: false, default: 0
    end
  end
end
