# frozen_string_literal: true

module V1
  class UserSerializer
    include FastJsonapi::ObjectSerializer

    set_type :user

    attributes :id, :name, :email, :mobile_number

    attributes :role do |object|
      object.role.name
    end

    attributes :organization do |object|
      object.organization.name
    end
  end
end
