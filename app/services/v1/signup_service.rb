# frozen_string_literal: true

module V1
  class SignupService
    def initialize(role: nil, params: nil)
      @role = role
      @params = params
    end

    def signup
      user = User.new(@params)
      user.role = @role
      ActiveRecord::Base.transaction do
        user.save!
      end
      { success: true }
    rescue StandardError
      errors = user.errors.full_messages.present? ? user.errors.full_messages : 
                {organization_name: I18n.t('organization.create.failed')}
      { success: false, errors: errors }
    end
  end
end
