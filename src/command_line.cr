require "option_parser"
require "yaml"
require "./config"

module MinionAPI
  class CommandLine
    property config : Config

    def initialize
      @config = parse_options
    end

    def parse_options
      empty_config = <<-EYAML
      ---
      bind: 0.0.0.0:3030
      pgurl:
      jwt: 
      EYAML

      config = Config.from_yaml(empty_config)

      host = ENV.has_key?("MINIONAPI_HOST") ? ENV["MINIONAPI_HOST"] : "0.0.0.0"
      port = ENV.has_key?("MINIONAPI_PORT") ? ENV["MINIONAPI_PORT"].to_i : 3030
      pgurl = ENV.has_key?("MINIONAPI_PG_URL") ? ENV["MINIONAPI_PG_URL"] : "postgresql://postgres:@127.0.0.1/minion_api_development?max_idle_pool_size=50&initial_pool_size=10"
      jwt = ENV.has_key?("MINIONAPI_JWT") ? ENV["MINIONAPI_JWT"] : ""

      OptionParser.new do |opts|
        opts.banner = "Minion API Server v#{MinionAPI::VERSION}\nUsage: minion-api [options]"
        opts.separator ""
        opts.on("-c", "--config CONFFILE", "The configuration file to read.") do |conf|
          config = Config.from_yaml(File.read(conf))
        end
        opts.on("-b", "--bind HOST:PORT", "The host and port to bind to.") do |h_p|
          if h_p =~ /:/
            h, p = h_p.split(":", 2)
          elsif h_p =~ /^\s*\d+\s*$/
            p = h_p
          else
            h = h_p
          end

          p ||= 3030
          host = h if h && !h.empty?
          port = p.to_i if p && (!p.to_s.empty? && p.to_i != 0)
        end
        opts.on("-u", "--url URL", "The PostgreSQL connection URL to use.") do |url|
          pgurl = url
        end
        opts.on("-j", "--jwt SECRET", "The JWT Secret for the API.") do |secret|
          jwt = secret
        end
        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
        opts.on("-v", "--version", "Show the current version of the Minion API server.") do
          puts "Minion API Server v#{MinionAPI::VERSION}"
          exit
        end
        opts.invalid_option do |flag|
          STDERR.puts "Error: #{flag} is not a valid option."
          STDERR.puts opts
          exit(1)
        end
      end.parse

      config.host = host
      config.port = port
      config.pgurl = pgurl
      config.jwt = jwt
      config
    end
  end
end
