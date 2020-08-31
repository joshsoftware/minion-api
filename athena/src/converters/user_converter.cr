module MinionAPI
  @[ADI::Register]
  struct UserConverter < ART::ParamConverterInterface
    def apply(request : HTTP::Request, configuration : Configuration) : Nil
      arg_name = configuration.name
      pp request.headers
      v = MinionAPI::User.validate(request.headers["Authorization"])
      pp "validated as:"
      pp v.to_json
      request.attributes.set arg_name, v.to_json, String
    rescue ex : KeyError
      puts ex
      User.raise_invalid
    end
  end
end
