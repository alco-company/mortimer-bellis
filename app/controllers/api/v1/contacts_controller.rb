module Api
  module V1
    class ContactsController < Api::ApiController
      def lookup
        @contact = case true
        when params[:email].present?; Customer.by_email(params[:email])
        when params[:phone].present?; Customer.by_phone(params[:phone])
        when params[:name].present?; Customer.by_name(params[:name])
        when params[:any].present?; Customer.by_fulltext(params[:any])
        end
        render json: @contact
      end

      def create
        tenant = current_resource_owner.tenant
        @contact = Customer.create tenant: tenant, name: params[:name], is_person: true, phone: params[:phone], email: params[:email]
        render json: @contact
      end

      private
        def resource_params
          params.permit(:name, :email, :phone, :tenant)
        end
    end
  end
end
