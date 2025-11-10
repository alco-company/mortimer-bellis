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
      if has_service("Dinero")
        es = provided_services.where(name: "Dinero").first
        tp= products.where(product_number: [ es.product_for_time, es.product_for_overtime, es.product_for_overtime_100 ]).order :base_amount_value
      else
        tp= products.where("product_number like ?", "Time%").order(:base_amount_value).take(3)
      end
      return tp if tp.count > 0

      # [
      #   SimpleProduct.new("Time", 100),
      #   SimpleProduct.new("Time50", 150),
      #   SimpleProduct.new("Time100", 200)
      # ]
      nil
    end
  end

  class_methods do
  end

  class SimpleProduct
    attr_accessor :product_number, :base_amount_value, :id

    def initialize(product_number, base_amount_value)
      @product_number = product_number
      @base_amount_value = base_amount_value
    end

    def id
      @id ||= SecureRandom.uuid
    end
  end
end
