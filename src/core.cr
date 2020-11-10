require "debug"
require "athena"
require "jwt"
require "pg"
require "sodium"
require "splay_tree_map"
require "./helpers/*"
require "./services/*"
require "./listeners/*"
require "./converters/*"
require "./controllers/api/v1"
require "./models/*"

module MinionAPI
  VERSION = "0.1.0"

  CONFIG = CommandLine.new.config
end
