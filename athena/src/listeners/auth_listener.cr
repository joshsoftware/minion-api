# Define and register a listener to handle authenticating requests.
module MinionAPI
  @[ADI::Register]
  struct Listeners::AuthListener
    include AED::EventListenerInterface

    # Specify that we want to listen on the `Request` event.
    def self.subscribed_events : AED::SubscribedEvents
      AED::SubscribedEvents{
        ART::Events::Request => 10,
      }
    end

    def initialize(@user_storage : MinionAPI::UserStorage); end

    def call(event : ART::Events::Request, _dispatcher : AED::EventDispatcherInterface) : Nil
      if {"/api/v1/auth/sigin", "/api/v1/health/heartbeat", "/api/v1/health/stats"}.includes? event.request.path
        return
      end
      # Return a 401 error if the token is missing or malformed
      raise ART::Exceptions::Unauthorized.new "Missing bearer token", "Bearer realm=\"My Blog\"" unless (auth_header = event.request.headers.get?("Authorization").try &.first) && auth_header.starts_with? "Bearer "

      # Get the JWT token from the Bearer header
      token = auth_header.lchop "Bearer "
      # Set the user in user storage
      @user_storage.user = MinionAPI::User.validate(token)
    end
  end
end
