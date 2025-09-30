class KillTenantJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    step = 1
    tenant = Tenant.find(args[:t_id])
    return if tenant.nil? || tenant == Tenant.first
    Tenant.transaction do
      purge_non_tenant_scoped_dependents(tenant)
      step = 2
      purge_tenant_scoped_models(tenant)
      step = 3
      purge_users(tenant)
      step = 4
      purge_teams(tenant)
      step = 5
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")
      tenant.logo.purge if tenant.logo.attached?
      step = 6
      tenant.destroy
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")
    rescue => e
      Rails.logger.error "Failed to delete tenant at step #{step} #{tenant.id}: #{e.message}"
      step == 6
    end
  end

  private

    def purge_non_tenant_scoped_dependents(tenant)
      user_ids = tenant.users.pluck(:id)
      tag_ids = tenant.tags.pluck(:id)
      begin
        if ActiveRecord::Base.connection.table_exists?(:taggings) && tag_ids.any?
          ActiveRecord::Base.connection.execute("DELETE FROM taggings WHERE tag_id IN (#{tag_ids.join(',')})")
        end
        if ActiveRecord::Base.connection.table_exists?(:sessions) && user_ids.any?
          ActiveRecord::Base.connection.execute("DELETE FROM sessions WHERE user_id IN (#{user_ids.join(',')})")
        end
        if ActiveRecord::Base.connection.table_exists?(:oauth_access_tokens) && user_ids.any?
          ActiveRecord::Base.connection.execute("DELETE FROM oauth_access_tokens WHERE resource_owner_id IN (#{user_ids.join(',')})")
        end
        if ActiveRecord::Base.connection.table_exists?(:oauth_access_grants) && user_ids.any?
          ActiveRecord::Base.connection.execute("DELETE FROM oauth_access_grants WHERE resource_owner_id IN (#{user_ids.join(',')})")
        end
        if ActiveRecord::Base.connection.table_exists?(:noticed_notifications) && user_ids.any?
          ActiveRecord::Base.connection.execute("DELETE FROM noticed_notifications WHERE recipient_id IN (#{user_ids.join(',')}) AND recipient_type='User'")
        end
        if ActiveRecord::Base.connection.table_exists?(:noticed_web_push_subs) && user_ids.any?
          ActiveRecord::Base.connection.execute("DELETE FROM noticed_web_push_subs WHERE user_id IN (#{user_ids.join(',')})")
        end
      rescue => e
        Rails.logger.error "Pre-purge cleanup failed for tenant #{tenant.id}: #{e.message}"
      end
    end

    def purge_tenant_scoped_models(tenant)
      order = DependencyGraph.purge_order
      order.each do |model_name|
        next if model_name == "tenants"
        begin
          klass = safe_constantize(model_name)
          next unless klass && klass.column_names.include?("tenant_id")
          klass.unscoped.where(tenant_id: tenant.id).delete_all
        rescue => e
          Rails.logger.error "Failed purging #{model_name} for tenant #{tenant.id}: #{e.message}"
        end
      end
    end

    def purge_users(tenant)
      tenant.users.order(id: :desc).each do |user|
        next if user.id == 1
        begin
          ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")
          user.mugshot.purge if user.mugshot.attached?
          user.time_materials.delete_all
          user.punches.delete_all
          user.punch_cards.delete_all
          user.filters.delete_all
          user.batches.delete_all
          user.background_jobs.delete_all
          user.access_grants.delete_all
          user.access_tokens.delete_all
          user.noticed_events.delete_all
          user.notifications.delete_all
          user.web_push_subscriptions.delete_all
          user.sessions.delete_all
          user.tags.delete_all
          user.taggings.delete_all
          user.tasks.delete_all
          user.calendars.delete_all
          user.destroy
          ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")
        rescue => e
          Rails.logger.error "Failed deleting user #{user.id} in tenant #{tenant.id}: #{e.message}"
        end
      end
    end

    def purge_teams(tenant)
      tenant.teams.order(id: :desc).each do |team|
        begin
          ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")
          team.noticed_events.delete_all
          team.calendars.delete_all
          team.settings.delete_all
          team.destroy
          ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")
        rescue => e
          Rails.logger.error "Failed deleting team #{team.id} in tenant #{tenant.id}: #{e.message}"
        end
      end
    end

    def safe_constantize(name)
      name.singularize.classify.constantize
    rescue NameError
      nil
    end
end
