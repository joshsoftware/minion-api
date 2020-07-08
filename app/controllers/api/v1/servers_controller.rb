# frozen_string_literal: true

module Api::V1
  class ServersController < BaseController
    before_action :load_server, only: %i[show update destroy]
    before_action :authorize_organization

    def index
      servers = Server.where(organization_id: current_user.organizations)
      response = V1::ServerSerializer.new(servers).serializable_hash
      success_response(data: response[:data])
    end

    def show
      response = V1::ServerSerializer.new(@server).serializable_hash
      success_response(data: response[:data])
    end

    def create
      response = V1::ServerService.new(params: server_params).create

      if response[:success]
        success_response(
          message: I18n.t('server.create.success'),
          data: response[:data],
          status_code: :created
        )
      else
        resource_error_response(
          message: I18n.t('server.create.failed'),
          status_code: :unprocessable_entity,
          errors: response[:errors]
        )
      end
    end

    def update
      response = V1::ServerService.new(params: server_params).update(@server)

      if response[:success]
        success_response(
          message: I18n.t('server.update.success'),
          data: response[:data]
        )
      else
        resource_error_response(
          message: I18n.t('server.update.failed'),
          status_code: :unprocessable_entity,
          errors: response[:errors]
        )
      end
    end

    def destroy
      if @server.discard
        success_response(
          message: I18n.t('server.delete.success')
        )
      else
        resource_error_response(
          status_code: :unprocessable_entity,
          message: I18n.t('server.delete.failed'),
          errors: @server.errors.messages
        )
      end
    end

    private

    def load_server
      @server = Server.find_by(id: params[:id])
    end

    def server_params
      params.require(:server).permit(:addresses, :aliases, :organization_id)
    end

    def authorize_organization
      if @server.present?
        authorize @server.organization_id, policy_class: V1::ServerPolicy
      else
        authorize server_params[:organization_id], policy_class: V1::ServerPolicy
      end
    end
  end
end
