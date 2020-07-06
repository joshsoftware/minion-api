class CreateAgentVersions < ActiveRecord::Migration[6.0]
  def change
    create_table :agent_versions do |t|
      t.string :version, null: false
      t.string :md5, null: false
      t.string :url, null: false
    end
  end
end
