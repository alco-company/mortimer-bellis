module Settingable
  extend ActiveSupport::Concern

  included do
    has_many :settings, as: :setable, dependent: :destroy

    # do not unless expressively allowed
    def can?(action, resource: nil, inverse: false, force: false)
      if !force && Current.get_user&.superadmin?
        return inverse ? false : true
      end
      key = action.to_s
      tenant = try(:tenant) || Current.tenant
      resource ||= self if self.class != Class
      all_settings = tenant.settings

      # true on resource-level
      result = can_query(key, all_settings.where(setable: resource), inverse) if resource
      return result if !result.nil?

      # true on user-level
      result = can_query(key, all_settings.where(setable: Current.user), inverse) unless resource.class == User
      return result if !result.nil?

      # true on user's team-level
      result = can_query(key, all_settings.where(setable: Current.user&.team), inverse) if Current.user&.team
      return result if !result.nil?

      # true on resource class-level
      result = can_query(key, all_settings.where(setable_type: resource.class.to_s, setable_id: nil), inverse)
      return result if !result.nil?

      # true on user class-level
      result = can_query(key, all_settings.where(setable_type: "User", setable_id: nil), inverse)
      return result if !result.nil?

      # true on team class-level
      result = can_query(key, all_settings.where(setable_type: "Team", setable_id: nil), inverse)
      return result if !result.nil?

      # true on tenant/global-level
      result = can_query(key, all_settings.where(setable: nil), inverse)
      return result if !result.nil?

      Rails.logger.debug "CAN? no specific setting found for #{key}, defaulting to false"
      # 1) Self - whatever that might be, TimeMaterial, User, Team, more
      # rel = settings
      # if rel.any?
      #   Rails.logger.debug "CAN? checking self settings for #{key}: #{rel.pluck(:key, :value)}"
      #   return false if rel.for_key(key).denied.exists?
      #   return true  if rel.for_key(key).allowed.exists?
      # end

      # if @user.present? && @user.settings.any?
      #   Rails.logger.debug "CAN? checking user settings for #{key}: #{rel.pluck(:key, :value)}"
      #   rel = @user.settings
      #   return false if rel.for_key(key).denied.exists?
      #   return true  if rel.for_key(key).allowed.exists?
      # end

      # # 2) Team
      # if respond_to?(:team) && team
      #   rel = team.settings
      #   if rel.any?
      #     Rails.logger.debug "CAN? checking team settings for #{key}: #{rel.pluck(:key, :value)}"
      #     return false if rel.for_key(key).denied.exists?
      #     return true  if rel.for_key(key).allowed.exists?
      #   end
      # end

      # # 3) Class-level for this resource (e.g., User defaults)
      # rel = self.class.settings_for_tenant(tenant)
      # if rel.any?
      #   Rails.logger.debug "CAN? checking #{self.class} class-level settings for #{key}: #{rel.pluck(:key, :value)}"
      #   return false if rel.for_key(key).denied.exists?
      #   return true  if rel.for_key(key).allowed.exists?
      # end

      # # 4) Class-level for Team (e.g., "all teams" defaults)
      # if respond_to?(:team) && team
      #   rel = Setting.where(setable_type: "Team", setable_id: nil)
      #   rel = rel.where(tenant:) if tenant
      #   if rel.any?
      #     Rails.logger.debug "CAN? checking Team class-level settings for #{key}: #{rel.pluck(:key, :value)}"
      #     return false if rel.for_key(key).denied.exists?
      #     return true  if rel.for_key(key).allowed.exists?
      #   end
      # end

      # # 5) Resource-level settings (e.g., specific time_material, background_job, more, settings)
      # if resource
      #   begin
      #     rel = resource.settings
      #     Rails.logger.debug "CAN? checking resource (#{resource&.name}) settings for #{key}: #{rel.pluck(:key, :value)}"
      #     return false if rel.for_key(key).denied.exists?
      #     return true  if rel.for_key(key).allowed.exists?
      #   rescue => e
      #     Rails.logger.error("Error checking resource (#{resource.inspect}) settings: #{e.message}")
      #   end
      # end

      # # 6) Tenant/global defaults (no setable_type/id)
      # if tenant
      #   rel = Setting.where(tenant:, setable_type: nil, setable_id: nil)
      #   Rails.logger.debug "CAN? checking tenant/global settings for #{key}: #{rel.pluck(:key, :value)}"
      #   return false if rel.for_key(key).denied.exists?
      #   return true  if rel.for_key(key).allowed.exists?
      # end

      # Default confirm (that user can perform the action)
      inverse ? true : false
    rescue
      Rails.logger.error "Error in can? for #{action} on #{self.class.name}# with resource #{resource.id rescue 'nil'}"
      inverse ? true : false
    end

    def can_query(key, rel, inverse = false)
      if rel.any?
        inverse ?
          (return true if rel.for_key(key).denied.exists?) :
          (return true if rel.for_key(key).allowed.exists?)
        inverse ?
          (return false if rel.for_key(key).allowed.exists?) :
          (return false if rel.for_key(key).denied.exists?)
      end
      nil
    end

    # do unless expressively denied
    def cannot?(action, resource: nil)
      can?(action, resource: resource, inverse: true)
      # key = action.to_s
      # tenant = try(:tenant) || Current.tenant

      # # 1) Self
      # rel = settings
      # return true if rel.for_key(key).denied.exists?
      # return false if rel.for_key(key).allowed.exists?

      # if Current.user.settings.any?
      #   rel = Current.user.settings
      #   return true if rel.for_key(key).denied.exists?
      #   return false if rel.for_key(key).allowed.exists?
      # end

      # # 2) Team
      # if respond_to?(:team) && team
      #   rel = team.settings
      #   if rel.any?
      #     return true if rel.for_key(key).denied.exists?
      #     return false if rel.for_key(key).allowed.exists?
      #   end
      # end

      # # 3) Class-level for this resource (e.g., User defaults)
      # rel = self.class.settings_for_tenant(tenant)
      # return true if rel.for_key(key).denied.exists?
      # return false if rel.for_key(key).allowed.exists?

      # # 4) Class-level for Team (e.g., "all teams" defaults)
      # if respond_to?(:team) && team
      #   rel = Setting.where(setable_type: "Team", setable_id: nil)
      #   rel = rel.where(tenant:) if tenant
      #   if rel.any?
      #     return true if rel.for_key(key).denied.exists?
      #     return false if rel.for_key(key).allowed.exists?
      #   end
      # end

      # # 5) Resource-level settings (e.g., specific time_material, background_job, more, settings)
      # if resource
      #   begin
      #     rel = resource.settings
      #     return true if rel.for_key(key).denied.exists?
      #     return false if rel.for_key(key).allowed.exists?
      #   rescue => e
      #     Rails.logger.error("Error checking resource (#{resource.inspect}) settings: #{e.message}")
      #   end
      # end

      # # 6) Tenant/global defaults (no setable_type/id)
      # if tenant
      #   rel = Setting.where(tenant:, setable_type: nil, setable_id: nil)
      #   return true if rel.for_key(key).denied.exists?
      #   return false if rel.for_key(key).allowed.exists?
      # end

      # # Default confirm (that user cannot perform the action)
      # true
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

    def should?(action, resource: nil)
      can?(action, resource:)
    end

    def shouldnt?(action, resource: nil)
      cannot?(action, resource:)
    end

    # get default setting value for key
    # start at self, then User, then self.team, Team, TimeMaterial, and eventually Tenant
    #
    def default(key, default)
      defaults = settings.where(key: key.to_s).any? ? settings.where(key: key.to_s) :
        User.settings.where(key: key.to_s).any? ? User.settings.where(key: key.to_s) :
        team.settings.where(key: key.to_s).any? ? team.settings.where(key: key.to_s) :
        Team.settings.where(key: key.to_s).any? ? Team.settings.where(key: key.to_s) :
        TimeMaterial.settings.where(key: key.to_s).any? ? TimeMaterial.settings.where(key: key.to_s) :
        Current.get_tenant.settings.where(key: key.to_s)
      defaults.count.positive? ? defaults.first.value : default
    rescue
      default
    end
  end

  class_methods do
    def can?(action, resource: nil)
      key = action.to_s
      tenant = try(:tenant) || Current.tenant

      # 3) Class-level for this resource (e.g., User defaults)
      rel = self.settings_for_tenant(tenant)
      return false if rel.for_key(key).denied.exists?
      return true  if rel.for_key(key).allowed.exists?

      # 5) Tenant/global defaults (no setable_type/id)
      if tenant
        stype = resource.is_a? Class ? resource.to_s : resource&.class&.name
        sid = resource.is_a? Class ? nil : resource&.id
        rel = Setting.where(tenant:, setable_type: stype, setable_id: sid)
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

      # 3) Class-level for this resource (e.g., User defaults)
      rel = self.settings_for_tenant(tenant)
      return true if rel.for_key(key).denied.exists?
      return false if rel.for_key(key).allowed.exists?

      # 5) Tenant/global defaults (no setable_type/id)
      if tenant
        stype = resource.is_a? Class ? resource.to_s : resource&.class&.name
        sid = resource.is_a? Class ? nil : resource&.id
        rel = Setting.where(tenant:, setable_type: stype, setable_id: sid)
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
