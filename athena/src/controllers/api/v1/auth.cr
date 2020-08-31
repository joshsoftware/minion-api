module MinionAPI
  class AuthController < ART::Controller
    @[ART::Get("/api/v1/auth/")]
    def index : String
      "TODO: Return appropriate top level response."
    end

    @[ART::QueryParam("email")]
    @[ART::QueryParam("password")]
    @[ART::Get("/api/v1/auth/signin")]
    def signin(email : String = "", password : String = "") : ART::Response
      signin_impl(email, password)
    end

    @[ART::Post("/api/v1/auth/signin")]
    def signin(request : HTTP::Request) : ART::Response
      raise ART::Exceptions::BadRequest.new "Missing request body." unless body = request.body

      data = JSON.parse(body.gets_to_end)

      handle_invalid_auth_credentials unless email = data["email"]?
      handle_invalid_auth_credentials unless password = data["password"]?

      signin_impl(email.not_nil!.as_s, password.not_nil!.as_s)
    end

    def signin_impl(email, password)
      if User.authenticate!(email, password)
        user = User.get_by(email: email)
        pp "Encoding {#{user}} with {#{JWT_SECRET}} and JWT::Algorithm::HS256"
        pp "JWT enc: #{JWT.encode(user, JWT_SECRET, JWT::Algorithm::HS256)}"

        pp "JWT dec: #{JWT.decode(JWT.encode(user, JWT_SECRET, JWT::Algorithm::HS256), JWT_SECRET, JWT::Algorithm::HS256)}"
        ART::Response.new(
          {
            accessToken: JWT.encode(user, JWT_SECRET, JWT::Algorithm::HS256),
          }.to_json,
          headers: HTTP::Headers{"content-type" => "application/json"}
        )
      else
        handle_invalid_auth_credentials
      end
    end

    private def handle_invalid_auth_credentials : Nil
      raise ART::Exceptions::Unauthorized.new "Invalid username or password.", "Basic realm=\"Minion Dashboard\""
    end
  end
end
