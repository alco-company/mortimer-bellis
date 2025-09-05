class KillTenantJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    tenant = Tenant.find(args[:t_id])
    return if tenant.nil? || tenant == Tenant.first
    Tenant.transaction do
      purge_non_tenant_scoped_dependents(tenant)
      purge_tenant_scoped_models(tenant)
      purge_users(tenant)
      tenant.teams.destroy_all
      tenant.logo.purge if tenant.logo.attached?
      tenant.delete
    rescue => e
      Rails.logger.error "Failed to delete tenant #{tenant.id}: #{e.message}"
      raise
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
      next if model_name == 'Tenant'
      klass = safe_constantize(model_name)
      next unless klass && klass.column_names.include?('tenant_id')
      begin
        klass.unscoped.where(tenant_id: tenant.id).delete_all
      rescue => e
        Rails.logger.error "Failed purging #{model_name} for tenant #{tenant.id}: #{e.message}"
        raise
      end
    end
  end

  def purge_users(tenant)
    tenant.users.order(id: :desc).each do |user|
      next if user.id == 1
      begin
        user.mugshot.purge if user.mugshot.attached?
        user.access_grants.delete_all
        user.access_tokens.delete_all
        user.notifications.delete_all
        user.web_push_subscriptions.delete_all
        user.sessions.delete_all
        user.delete
      rescue => e
        Rails.logger.error "Failed deleting user #{user.id} in tenant #{tenant.id}: #{e.message}"
        raise
      end
    end
  end

  def safe_constantize(name)
    name.constantize
  rescue NameError
    nil
  end
end
