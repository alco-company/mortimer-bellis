module BatchActions
  extend ActiveSupport::Concern

  included do
    private
      def set_batch
        @batch = Batch.where(user: Current.user, entity: resource_class.to_s).take || Batch.create(user: Current.user, entity: resource_class.to_s)
      end
  end
end
