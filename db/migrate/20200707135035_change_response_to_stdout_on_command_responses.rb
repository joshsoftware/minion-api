class ChangeResponseToStdoutOnCommandResponses < ActiveRecord::Migration[6.0]
  def change
    rename_column :command_responses, :response, :stdout
  end
end
