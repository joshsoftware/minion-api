# frozen_string_literal: true

module V1
  class ServerSerializer
    include FastJsonapi::ObjectSerializer

    set_type :server
    attributes :id, :addresses, :aliases, :organization_id

    attributes :discarded do |object|
      object.discarded?
    end
  end
end
