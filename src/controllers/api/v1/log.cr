module MinionAPI
  @[ADI::Register(public: true)]
  class LogController < ART::Controller
    def initialize(@user_storage : MinionAPI::UserStorage); end

    @[ART::Get("/api/v1/log/count")]
    def getCount : ART::Response
      ART::Response.new(
        {
          count: Log.count,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end

    @[ART::Post("/api/v1/log/services")]
    def get_services(request : HTTP::Request) : ART::Response
      raise ART::Exceptions::BadRequest.new "Missing request body." unless body = request.body

      data = JSON.parse(body.gets_to_end)

      debug!(data)

      servers = data["servers"].as_a.map(&.as_s)
      services = MinionAPI::Log.get_unique_services(servers)

      ART::Response.new(
        {
          data: services,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end

    @[ART::Post("/api/v1/log/get")]
    def get_data(request : HTTP::Request) : ART::Response
      raise ART::Exceptions::BadRequest.new "Missing request body." unless body = request.body

      data = JSON.parse(body.gets_to_end)

      data_ary = data["criteria"].as_a.map(&.as_h)
      limit = 500
      data_ary.each do |h|
        if h["criteria"] == "limit"
          limit = h["value"].as_i
          break
        end
      end

      data_ary = data_ary.select { |h| h["criteria"] != "limit" }

      log_data = MinionAPI::Log.get_data(
        limit: limit,
        uuid: data["uuid"].as_s,
        criteria: data_ary.map do |h|
          new_h = Hash(String, String).new
          h.each { |k, v| new_h[k] = v.as_s }
          new_h
        end,
        dedups: data.as_h.has_key?("dedups") ? data["dedups"].as_a.map(&.as_s) : [] of String,
        next_from: data.as_h.has_key?("next_from") ? data["next_from"].as_s : nil
      )

      ART::Response.new(
        {
          data: log_data,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end
  end
end
