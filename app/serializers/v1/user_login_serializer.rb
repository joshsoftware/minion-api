# frozen_string_literal: true

module V1
  class UserLoginSerializer
    include FastJsonapi::ObjectSerializer

    set_type :user

    attributes :id, :name, :email, :mobile_number

    attribute :role do |object|
      object.role.name
    end

    attribute :organization do |object|
      object.organization.name
    end

    attribute :jwt_token do |object|
      JwtService.encode(object)
    end
  end
end
