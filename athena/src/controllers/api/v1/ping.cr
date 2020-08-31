# This controller is used just to provide a simple heartbeat/healthcheck
# access point for the API server itself.
module MinionAPI
  class HealthController < ART::Controller
    @[ART::Get("/api/v1/health/heartbeat")]
    def heartbeat : ART::Response
      ART::Response.new(
        {
          beat: Time.utc,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end

    @[ART::Get("/api/v1/health/stats")]
    def stats : ART::Response
      stats = GC.stats
      data = {
        total: stats.total_bytes,
        free:  stats.free_bytes,
        heap:  stats.heap_size,
      }

      ART::Response.new(
        {
          data: data,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end
  end
end
