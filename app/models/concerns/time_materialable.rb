module TimeMaterialable
  extend ActiveSupport::Concern

  included do
    has_many :time_materials, dependent: :destroy
  end

  class_methods do
    def user_list
      rate = Current.get_tenant.time_products&.first&.base_amount_value
      # rate ||= Current.get_user.default(:default_time_material_rate, 0)
      User.by_tenant.with_effective_hourly_rate(rate).order(name: :asc)
    end
  end
end
