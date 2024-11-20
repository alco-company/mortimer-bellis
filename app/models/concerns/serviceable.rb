module Serviceable
  extend ActiveSupport::Concern

  included do
    has_many :provided_services, dependent: :destroy

    def has_service(service)
      provided_services.where(name: service).exists?
    end
  end

  class_methods do
  end
end
