# frozen_string_literal: true

module V1
  class OrganizationSerializer
    include FastJsonapi::ObjectSerializer

    set_type :organization

    attributes :id, :name
  end
end