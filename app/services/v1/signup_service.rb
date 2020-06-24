# frozen_string_literal: true

module V1
  class SignupService
    def initialize(organization: nil, role: nil, params: nil)
      @organization = organization
      @role = role
      @params = params
    end

    def signup
      user = User.new(@params)
      user.organization = @organization
      user.role = @role

      ActiveRecord::Base.transaction do
        user.save!
      end
      { success: true }
    rescue StandardError
      { success: false, errors: user.errors.full_messages }
    end
  end
end
