# frozen_string_literal: true

module V1
  class UserSerializer
    include FastJsonapi::ObjectSerializer

    set_type :user

    attributes :id, :name, :email, :mobile_number, :role

    attributes :discarded do |object|
      object.discarded?
    end

    attributes :organizations, serializer: OrganizationSerializer
  end
end
