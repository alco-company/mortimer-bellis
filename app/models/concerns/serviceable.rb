module Serviceable
  extend ActiveSupport::Concern

  included do
    has_many :provided_services, dependent: :destroy

    def has_service(service)
      provided_services.where(name: service).exists?
    end

    def erp_service
      has_service("Dinero") ? provided_services.where(name: "Dinero").first : nil
    end

    def time_products
      return [] unless has_service("Dinero")
      es = provided_services.where(name: "Dinero").first
      products.where product_number: [ es.product_for_time, es.product_for_overtime, es.product_for_overtime_100 ]
    end
  end

  class_methods do
  end
end
