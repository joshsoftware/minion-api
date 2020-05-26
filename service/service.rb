module Minion
  module Service
    def self.start
=begin
    # module TLSHandler
    #   def post_init
    #     start_tls(:private_key_file => '/tmp/server.key', :cert_chain_file => '/tmp/server.crt', :verify_peer => false)
    #   end
    # end

    App = lambda do |env|
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env)

        ws.on :message do |event|
          ws.send(event.data)
        end

        ws.on :close do |event|
          p [:close, event.code, event.reason]
          ws = nil
        end

        # Return async Rack response
        ws.rack_response

      else
        # Normal HTTP request
        [200, { 'Content-Type' => 'text/plain' }, ['Hello']]
      end
    end
  end
end
=end
      EM.run {
        EM::WebSocket.start(
          :host => "0.0.0.0",
          :port => 9000
        ) do |ws|
          ws.onopen { |handshake|
            puts "WebSocket connection opened from #{ws.remote_ip}"
            ws.send("{\"action\":\"connected\", \"your_ip\":\"#{ws.remote_ip}\"}")
          }

          ws.onclose { puts "WebSocket Connection closed for #{ws.remote_ip}" }

          ws.onmessage { |msg|
            # Parse the message (JSON) and if it's a subscribe, listen for
            # changes to the commands table where its server ID is this server's
            # id. Otherwise, it's going to be an add line command, so we need
            # to add that to the database...which will trigger an update to
            # the first situation.
            #
            # This is for the DASHBOARD to subscribe for new command output
            puts "Recieved message from #{ws.remote_ip}: #{msg}"
# binding.pry
            message = JSON.parse(msg).deep_symbolize_keys
            case message[:action]
            when 'output_command'
              operation = proc {
                EM.run {
                  $pool.with do |conn|

                    RethinkDB::RQL.new.table('commands').get(message[:command_id]).changes.run(conn).each do |cmd|

                      # Here we send more than just the most recent item just
                      # in case for some reason the client didn't see the other
                      # output lines.
# binding.pry
                      msg = { stdout: cmd['new_val']['stdout'], stderr: cmd['new_val']['stderr'] }
                      ws.send msg.to_json
                    end
                  end
                }
              }
            when 'new_commands'
              # TODO: Authenticate the request and verify identity so you can't
              # subscribe to changes for somebody else's server.
              # Client wants to be notified when there are new commands
              # to be executed.
              operation = proc {
                $pool.with do |conn|
# binding.pry
                  EM.run {
                  # RethinkDB::RQL.new.table('commands').changes.run(conn).each { |cmd| puts cmd; ws.send cmd.to_json }

                    RethinkDB::RQL.new.table('commands').filter do |cmd|
                      cmd['server_id'].eq(message[:server_id])
                    end.changes.run(conn).each { |cmd| ws.send ({action: "new_commands"}.merge(cmd)).to_json }
                  }
                end
              }
            when 'update_command'
              # Client is adding new output to a command. Look for the
              # command by ID and update it accordingly (command.add_line)
              operation = proc {
                command = Command.find(message[:command_id])
                # TODO: Make sure the command's server ID matches this server's id
                [:stdout, :stderr].each do |dev|
                  command.add_line(dev, message[dev])
                end
              }
            else
              operation = {}
            end

            callback = proc { |result|
              # TODO: Send result to websocket client (result should be hash)
              ws.send "Result: #{result.to_json}"
            }

            # TODO: Try to figure out the error. If it's a disconnect or
            # something, try to reconnect. Otherwise log the error and
            # move on.
            errback = proc { |err|
binding.pry
              puts err
            }

            EventMachine.defer(operation, callback, errback)
          }
        end
      }
    end
  end
end

# A Monkey Patch to get the websocket's remote ip address
class EM::WebSocket::Connection
  def remote_ip
    get_peername[2,6].unpack('nC4')[1..4].join('.')
  end
end
