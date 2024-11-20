module Tenantable
  extend ActiveSupport::Concern

  included do
    # Tenant is actually not optional, but we not do want
    # to generate a SELECT query to verify the tenant is
    # there every time. We get this protection for free
    # because of the `Current.tenant_or_raise!`
    # and also through FK constraints.
    belongs_to :tenant
    # default_scope { where(tenant: Current.tenant_or_raise!) }

    scope :by_tenant, ->(acc = nil) {
      return where(tenant: acc) unless acc.nil?
      if Current.user.present?
        case Current.user.role
        when "superadmin"
          Current.user.global_queries? ? all : where(tenant: Current.tenant)
        when "admin", "user"
          where(tenant: Current.tenant)
        end
      else
        if Current.tenant.present?
          where(tenant: Current.tenant)
        else
          all
        end
      end
    }
  end

  class_methods do
  end
end
