module BatchActions
  extend ActiveSupport::Concern

  included do
    private
      def set_batch
        @batch = Batch.where(tenant: Current.tenant, user: Current.user, entity: resource_class.to_s).take ||
                 Batch.create(tenant: Current.tenant, user: Current.user, entity: resource_class.to_s, ids: "", all: true)
      end
  end
end
