module Settingable
  extend ActiveSupport::Concern

  included do
    has_many :settings, as: :setable

    # do not unless expressively allowed
    def can?(action)
      settings.where(key: action.to_s, value: "true").count.positive? or self.class.can?(action)
    end

    # do unless expressively denied
    def cannot?(action)
      settings.where(key: action.to_s, value: "false").count.positive? or self.class.cannot?(action)
    end

    def should?(action)
      can?(action)
    end

    def shouldnt?(action)
      cannot?(action)
    end

    def default(key, default)
      defaults = Setting.by_tenant.where(key: key.to_s)
      defaults.count.positive? ? defaults.first.value : default
    end
  end

  class_methods do
    def can?(action)
      Setting.by_tenant.where(setable_type: self.to_s, setable_id: nil, key: action.to_s, value: "true").count.positive?
    end
    def cannot?(action)
      Setting.by_tenant.where(setable_type: self.to_s, setable_id: nil, key: action.to_s, value: "false").count.positive?
    end
  end
end
