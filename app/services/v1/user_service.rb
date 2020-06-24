# frozen_string_literal: true

module V1
  class UserService
    def initialize(organization_id: nil, role: nil, params: nil)
      @organization_id = organization_id
      @role = role
      @params = params
      @page = params[:page]
      @per = params[:per]
      @query = params[:query]
    end

    def create
      user = User.new(@params)
      user.organization_id = @organization_id
      user.role = @role

      if user.save
        { success: true, data: V1::UserSerializer.new(user).serializable_hash[:data] }
      else
        { success: false, errors: user.errors.messages }
      end
    end
  end
end
