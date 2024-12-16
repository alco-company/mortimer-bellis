module Api
  module V1
    class TicketsController < Api::ApiController
      def create
        tenant = current_resource_owner.tenant
        @ticket = Call.create tenant: tenant, direction: params[:direction], phone: params[:phone]
        render json: @ticket
      end
    end
  end
end
