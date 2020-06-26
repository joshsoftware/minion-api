# frozen_string_literal: true

module V1
  class UserLoginSerializer
    include FastJsonapi::ObjectSerializer

    set_type :user

    attributes :id, :name, :email, :mobile_number, :role

    attributes :organizations, serializer: OrganizationSerializer

    attribute :jwt_token do |object|
      JwtService.encode(object)
    end
  end
end
