class AddStderrToCommandResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :command_responses, :stderr, :string, array: true, null: false, default: []
  end
end
