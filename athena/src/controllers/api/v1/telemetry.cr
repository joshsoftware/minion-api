module MinionAPI
  @[ADI::Register(public: true)]
  class TelemetryController < ART::Controller
    def initialize(@user_storage : MinionAPI::UserStorage); end

    @[ART::Get("/api/v1/telemetry/count")]
    def get_count : ART::Response
      ART::Response.new(
        {
          count: Telemetry.count,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end

    @[ART::Post("/api/v1/telemetry/primary_data_keys")]
    def get_primary_data_keys(request : HTTP::Request) : ART::Response
      raise ART::Exceptions::BadRequest.new "Missing request body." unless body = request.body

      data = JSON.parse(body.gets_to_end)

      debug!(data)

      servers = data["servers"].as_a.map(&.as_s)
      pdk_data = MinionAPI::Telemetry.get_primary_data_keys(servers)

      ART::Response.new(
        {
          data: pdk_data,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end

    @[ART::Post("/api/v1/telemetry/get")]
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
      debug!(data_ary)

      begin
        telemetry_data = MinionAPI::Telemetry.get_data(
          limit: limit,
          uuid: data["uuid"].as_s,
          criteria: data_ary.map do |h|
            new_h = Hash(String, String).new
            h.each { |k, v| new_h[k] = v.as_s }
            new_h
          end
        )
      rescue ex : Exception
        debug!(ex)
      end

      ART::Response.new(
        {
          data: telemetry_data,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end
  end
end
