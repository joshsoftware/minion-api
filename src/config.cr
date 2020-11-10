require "yaml"

@[YAML::Serializable::Options(emit_nulls: true)]
module MinionAPI
  class Config
    include YAML::Serializable
    include YAML::Serializable::Unmapped

    @[YAML::Field(key: "bind")]
    property port : String? = nil

    @[YAML::Field(key: "host")]
    property host : String = "0.0.0.0"

    @[YAML::Field(key: "port")]
    property port : Int = 3030

    @[YAML::Field(key: "pgurl")]
    property syncinterval : String = "postgresql://postgres:@127.0.0.1/minion_api_development?max_idle_pool_size=50&initial_pool_size=10"

    @[YAML::Field(key: "jwt")]
    property jwt : String = ""
  end
end
