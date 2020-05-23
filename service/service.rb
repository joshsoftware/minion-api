require 'em-websocket'

class Minion
  class Service
    def self.start
      EM.run {
        EM::WebSocket.start(
          :host => "0.0.0.0",
          :port => 9000,
          :secure => true,
          :tls_options => {
            :private_key_file => File.join(Dir.pwd, 'service', 'ssl', 'server.key'),
            :cert_chain_file => File.join(Dir.pwd, 'service', 'ssl', 'server.crt')
          }
        ) do |ws|
          ws.onopen { |handshake|
            puts "WebSocket connection opened from #{ws.remote_ip}"

            # Access properties on the EM::WebSocket::Handshake object, e.g.
            # path, query_string, origin, headers

            # Publish message to the client
            # ws.send "Hello Client, you connected to #{handshake.path}"
          }

          ws.onclose { puts "Connection closed" }

          ws.onmessage { |msg|
            # puts "Recieved message: #{msg}"
            # ws.send "Pong: #{msg}"
            operation = proc {
              # TODO: Have the operation update the database
              # and return the new object in a literal 'return' statement
              Minion::Service.update_db
            }

            callback = proc { |result|
              # TODO: Send result to websocket client (result should be hash)
              ws.send result.to_json
            }

            # TODO: Try to figure out the error. If it's a disconnect or
            # something, try to reconnect. Otherwise log the error and
            # move on.
            errback = proc { |err|
              puts err
            }

            EventMachine.defer(operation, callback, errback)
          }
        end
      }
    end

    def self.update_db
      # This is a spoofed db update method for the time being.
      hsh = {
        command: {
          id: "abc123",
          initiated_at: Time.now.utc,
          stdout: {
            lines: [
              { output: "asdfasdf asdfasdfa asfd...", at: Time.now.utc },
              { output: "asdfasdf asdfasdfa asfd...", at: Time.now.utc },
              { output: "asdfasdf asdfasdfa asfd...", at: Time.now.utc },
            ]
          }
        }
      }
      return hsh
    end
  end
end

# A Monkey Patch to get the websocket's remote ip address
class EM::WebSocket::Connection
  def remote_ip
    get_peername[2,6].unpack('nC4')[1..4].join('.')
  end
end
