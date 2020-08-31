# TODO: Write documentation for `MinionAPI`
require "debug"
require "athena"
require "jwt"
require "pg"
require "sodium"
require "minion-common/minion/splay_tree_map"
require "./helpers/*"
require "./services/*"
require "./listeners/*"
require "./converters/*"
require "./controllers/api/v1"
require "./models/*"

module MinionAPI
  VERSION = "0.1.0"

  JWT_SECRET = ENV["JWT_SECRET"]
  DBH        = DB.open(ENV["PG_URL"].as(String))
  ART.run(port: 3030)
end
