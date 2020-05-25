# frozen_string_literal: true

# Minion
module Minion
  # API
  class API < Grape::API
    format :json

    resource :commands do
      desc 'Returns all the commands issued (big query)'
      get :all do
        commands = []
        $pool.with do |conn|
          RethinkDB::RQL.new.table("commands").run(conn).each do |cmd|
            commands << cmd
          end
        end
        return commands
      end
    end
  end
end
