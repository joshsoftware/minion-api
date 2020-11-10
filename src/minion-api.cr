# TODO: Write documentation for `MinionAPI`
require "./core"

module MinionAPI
  ART.run(host: CONFIG.host, port: CONFIG.port)
end
