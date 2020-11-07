module MinionAPI
  @[ADI::Register(public: true)]
  class ServerController < ART::Controller
    def initialize(@user_storage : MinionAPI::UserStorage); end

    @[ART::QueryParam("organizations")]
    @[ART::Get("/api/v1/server/summary")]
    def getServerSummary(organizations : String? = nil) : ART::Response
      user_orgs = @user_storage.user.organizations || [] of String
      orgs = if organizations.nil?
               user_orgs.map { |o| o.as(Organization).uuid.not_nil! }
             else
               organizations.split(/\s*,\s*/)
             end

      servers = Server.get_summary_by(orgs)
      pp servers
      ART::Response.new(
        {
          servers: Server.get_summary_by(orgs),
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end

    @[ART::Post("/api/v1/server/names")]
    def get_names(request : HTTP::Request) : ART::Response
      raise ART::Exceptions::BadRequest.new "Missing request body." unless body = request.body

      data = JSON.parse(body.gets_to_end)
      debug!(data)

      servers = data["servers"].as_a.map(&.as_s)
      names = Server.get_names_from_ids(servers)
      ART::Response.new(
        {
          data: names,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end
  end
end
