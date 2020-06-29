# frozen_string_literal: true

module V1
  class UserService
    def initialize(role: nil, params: nil)
      @role = role
      @params = params
      @page = params[:page]
      @per = params[:per]
      @query = params[:query]
    end

    def create
      user = User.new(@params)
      user.role = @role

      if user.save
        { success: true, data: V1::UserSerializer.new(user).serializable_hash[:data] }
      else
        { success: false, errors: user.errors.messages }
      end
    end
  end
end
