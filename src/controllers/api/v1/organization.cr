module MinionAPI
  @[ADI::Register(public: true)]
  class OrganizationController < ART::Controller
    def initialize(@user_storage : MinionAPI::UserStorage); end

    @[ARTA::Get("/api/v1/organizations")]
    def getOrganizations : ART::Response
      ART::Response.new(
        {
          organizations: Organization.all.map { |o| o.to_h },
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end
  end
end
