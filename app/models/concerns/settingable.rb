module Settingable
  extend ActiveSupport::Concern

  included do
    has_many :settings, as: :setable, dependent: :destroy

    # do not unless expressively allowed
    def can?(action, resource: nil)
      key = action.to_s
      tenant = try(:tenant) || Current.tenant

      # 1) Self
      rel = settings
      return false if rel.for_key(key).denied.exists?
      return true  if rel.for_key(key).allowed.exists?

      # 2) Team
      if respond_to?(:team) && team
        rel = team.settings
        return false if rel.for_key(key).denied.exists?
        return true  if rel.for_key(key).allowed.exists?
      end

      # 3) Class-level for this resource (e.g., User defaults)
      rel = self.class.settings_for_tenant(tenant)
      return false if rel.for_key(key).denied.exists?
      return true  if rel.for_key(key).allowed.exists?

      # 4) Class-level for Team (e.g., "all teams" defaults)
      if respond_to?(:team) && team
        rel = Setting.where(setable_type: "Team", setable_id: nil)
        rel = rel.where(tenant:) if tenant
        return false if rel.for_key(key).denied.exists?
        return true  if rel.for_key(key).allowed.exists?
      end

      # 5) Resource-level settings (e.g., specific time_material, background_job, more, settings)
      if resource
        begin
          rel = resource.settings
          return false if rel.for_key(key).denied.exists?
          return true  if rel.for_key(key).allowed.exists?
        rescue => e
          Rails.logger.error("Error checking resource (#{resource.inspect}) settings: #{e.message}")
        end
      end

      # 6) Tenant/global defaults (no setable_type/id)
      if tenant
        rel = Setting.where(tenant:, setable_type: nil, setable_id: nil)
        return false if rel.for_key(key).denied.exists?
        return true  if rel.for_key(key).allowed.exists?
      end

      # Default confirm (that user can perform the action)
      false
    end

    # do unless expressively denied
    def cannot?(action, resource: nil)
      key = action.to_s
      tenant = try(:tenant) || Current.tenant

      # 1) Self
      rel = settings
      return true if rel.for_key(key).denied.exists?
      return false if rel.for_key(key).allowed.exists?

      # 2) Team
      if respond_to?(:team) && team
        rel = team.settings
        return true if rel.for_key(key).denied.exists?
        return false if rel.for_key(key).allowed.exists?
      end

      # 3) Class-level for this resource (e.g., User defaults)
      rel = self.class.settings_for_tenant(tenant)
      return true if rel.for_key(key).denied.exists?
      return false if rel.for_key(key).allowed.exists?

      # 4) Class-level for Team (e.g., "all teams" defaults)
      if respond_to?(:team) && team
        rel = Setting.where(setable_type: "Team", setable_id: nil)
        rel = rel.where(tenant:) if tenant
        return true if rel.for_key(key).denied.exists?
        return false if rel.for_key(key).allowed.exists?
      end

      # 5) Resource-level settings (e.g., specific time_material, background_job, more, settings)
      if resource
        begin
          rel = resource.settings
          return true if rel.for_key(key).denied.exists?
          return false if rel.for_key(key).allowed.exists?
        rescue => e
          Rails.logger.error("Error checking resource (#{resource.inspect}) settings: #{e.message}")
        end
      end

      # 6) Tenant/global defaults (no setable_type/id)
      if tenant
        rel = Setting.where(tenant:, setable_type: nil, setable_id: nil)
        return true if rel.for_key(key).denied.exists?
        return false if rel.for_key(key).allowed.exists?
      end

      # Default confirm (that user cannot perform the action)
      true
    end
    #   key = action.to_s

    #   # Explicit deny at self level
    #   return true if settings.where(key: action).denied.exists?

    #   # Team-level explicit deny
    #   return true if respond_to?(:team) && team && team.settings.where(key: action).denied.exists?

    #   # Class-level explicit deny
    #   return true if self.class.settings.where(key: action).denied.exists?

    #   # Tenant/global explicit deny
    #   tenant = try(:tenant) || Current.tenant
    #   if tenant
    #     return true if Setting.where(tenant:, setable_type: nil, setable_id: nil).where(key: action).denied.exists?
    #   end

    #   false
    # end

    def should?(action)
      can?(action)
    end

    def shouldnt?(action)
      cannot?(action)
    end

    def default(key, default)
      defaults = settings.where(key: key.to_s).any? ? settings.where(key: key.to_s) :
        team.settings.where(key: key.to_s).any? ? team.settings.where(key: key.to_s) :
        Current.get_tenant.settings.where(key: key.to_s)
      defaults.count.positive? ? defaults.first.value : default
    end
  end

  class_methods do
    def can?(action)
      key = action.to_s
      tenant = try(:tenant) || Current.tenant

      # 3) Class-level for this resource (e.g., User defaults)
      rel = self.settings_for_tenant(tenant)
      return false if rel.for_key(key).denied.exists?
      return true  if rel.for_key(key).allowed.exists?

      # 5) Tenant/global defaults (no setable_type/id)
      if tenant
        rel = Setting.where(tenant:, setable_type: nil, setable_id: nil)
        return false if rel.for_key(key).denied.exists?
        return true  if rel.for_key(key).allowed.exists?
      end

      # Default confirm (that user can perform the action)
      false
    end

    # do unless expressively denied
    def cannot?(action)
      key = action.to_s
      tenant = try(:tenant) || Current.tenant

      # 3) Class-level for this resource (e.g., User defaults)
      rel = self.settings_for_tenant(tenant)
      return true if rel.for_key(key).denied.exists?
      return false if rel.for_key(key).allowed.exists?

      # 5) Tenant/global defaults (no setable_type/id)
      if tenant
        rel = Setting.where(tenant:, setable_type: nil, setable_id: nil)
        return true if rel.for_key(key).denied.exists?
        return false if rel.for_key(key).allowed.exists?
      end

      # Default confirm (that user cannot perform the action)
      true
    end
    def settings
      Setting.by_tenant.where(setable_type: self.to_s, setable_id: nil)
    end
    # Class-level settings for a specific tenant
    def settings_for_tenant(tenant)
      scope = Setting.where(setable_type: name, setable_id: nil)
      tenant ? scope.where(tenant:) : scope
    end
  end
end
