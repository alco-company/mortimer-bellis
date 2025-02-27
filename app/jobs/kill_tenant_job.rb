class KillTenantJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    tenant = Tenant.find(args[:t_id])
    if tenant
      Tenant.transaction do
        tenant.background_jobs.destroy_all
        tenant.batches.destroy_all
        tenant.calendars.destroy_all
        tenant.calls.destroy_all
        tenant.customers.destroy_all
        tenant.dashboards.destroy_all
        tenant.events.destroy_all
        tenant.filters.destroy_all
        tenant.invoices.destroy_all
        tenant.invoice_items.destroy_all
        tenant.locations.destroy_all
        tenant.products.destroy_all
        tenant.projects.destroy_all
        tenant.provided_services.destroy_all
        tenant.punch_cards.destroy_all
        tenant.punch_clocks.destroy_all
        tenant.punches.destroy_all
        tenant.settings.destroy_all
        tenant.tasks.destroy_all
        tenant.time_materials.destroy_all

        tenant.users.each do |user|
          next if user.id == 1
          user.mugshot.purge if user.mugshot.attached?
          user.access_grants.destroy_all
          user.access_tokens.destroy_all
          user.notifications.destroy_all
          user.web_push_subscriptions.destroy_all
          user.delete
        end

        tenant.teams.destroy_all
        tenant.logo.purge if tenant.logo.attached?
        tenant.delete
      end
    end
  end
end
