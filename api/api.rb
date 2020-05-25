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
      desc 'Returns a the command specified by id (a uuid)'
      params do
        requires :id, type: String, desc: 'Command UUID (string)'
      end
      route_param :id do
        get do
          c = Command.find(params[:id])
          c.to_h
        end
      end
    end
  end
end
