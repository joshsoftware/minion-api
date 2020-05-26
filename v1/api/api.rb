# frozen_string_literal: true

# Minion
module Minion
  # API
  class API < Grape::API
    format :json
    logger.formatter = GrapeLogging::Formatters::Default.new
    use GrapeLogging::Middleware::RequestLogger, { logger: logger }

    resource :commands do
      desc 'Sets the stage for CORS from the browser'
      options do
        header 'Access-Control-Allow-Origin', '*'
        header 'Access-Control-Allow-Headers', '*'
      end

      desc 'Returns all the commands issued (big query)'
      get :all do
        header 'Access-Control-Allow-Origin', '*'
        commands = []
        $pool.with do |conn|
          RethinkDB::RQL.new.table("commands").run(conn).each do |cmd|
            commands << cmd
          end
        end
        return commands
      end

      params do
        requires :id, type: String, desc: 'Command UUID (string)'
      end
      route_param :id do
        desc 'Returns a the command specified by id (a uuid)'
        get do
          header 'Access-Control-Allow-Origin', '*'
          c = Command.find(params[:id])
          c.to_h
        end

        desc 'Updates the command'
        patch do
          header 'Access-Control-Allow-Origin', '*'
          c = Command.find(params[:id])
          cmd = JSON.parse(request.body.read).deep_symbolize_keys
          $pool.with do |conn|
            RethinkDB::RQL.new.db('minion').table('commands').get(c.id).update { |command|
              { started_at: cmd[:started_at], completed_at: cmd[:completed_at] }
            }.run(conn)
          end
        end
      end



      desc 'Creates a command to be executed by the minion agent'
      params {}
      post do
        # curl -i -X POST -d @test/new_command.json http://localhost:9292/commands
        header 'Access-Control-Allow-Origin', '*'
        cmd = JSON.parse(request.body.read)
        Command.create(cmd).to_h
      end
    end
  end
end
