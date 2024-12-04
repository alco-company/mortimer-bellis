module Settingable
  extend ActiveSupport::Concern

  included do
    has_many :settings, as: :setable

    def can?(action)
      settings.where(key: action.to_s, value: "true").count.positive? or self.class.can?(action)
    end

    def should?(action)
      can?(action)
    end
  end

  class_methods do
    def can?(action)
      Setting.by_tenant.where(setable_type: self.to_s, setable_id: nil, key: action.to_s, value: "true").count.positive?
    end
  end
end
