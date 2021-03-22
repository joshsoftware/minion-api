module MinionAPI
  @[ADI::Register(public: true)]
  class UserController < ART::Controller
    property user : MinionAPI::User.class = User

    def initialize(@user_storage : MinionAPI::UserStorage); end

    @[ARTA::Get("/api/v1/user/count")]
    def getCount : ART::Response
      ART::Response.new(
        {
          count: @user.count,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end

    # TODO: Make a smarter version that can paginate so that a smart UI can
    # implement an infinite scrolling lazy loading function to just get the
    # users that are currently of interest.
    @[ARTA::Get("/api/v1/users")]
    def getUsers : ART::Response
      ART::Response.new(
        {
          users: @user.all,
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end

    @[ARTA::Get("/api/v1/user/:uuid")]
    def getUser(uuid : String) : ART::Response
      ART::Response.new(
        {
          user: @user.find(uuid: uuid),
        }.to_json,
        headers: HTTP::Headers{"content-type" => "application/json"}
      )
    end
  end
end
