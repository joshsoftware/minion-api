module MinionAPI
  @[ADI::Register(public: true)]
  class UserController < ART::Controller
    def initialize(@user_storage : MinionAPI::UserStorage); end

    @[ART::Get("/api/v1/user/count")]
    def getCount : ART::Response
      ART::Response.new(
        {
          count: User.count,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end

    # TODO: Make a smarter version that can paginate so that a smart UI can
    # implement an infinite scrolling lazy loading function to just get the
    # users that are currently of interest.
    @[ART::Get("/api/v1/users")]
    def getUsers : ART::Response
      ART::Response.new(
        {
          users: User.all,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end

    @[ART::Get("/api/v1/user/:uuid")]
    def getUser(uuid : String) : ART::Response
      ART::Response.new(
        {
          user: User.find(uuid: uuid),
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end
  end
end
