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
  end
end
