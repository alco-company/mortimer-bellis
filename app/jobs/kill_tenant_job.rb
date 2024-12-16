class KillTenantJob < ApplicationJob
  queue_as :default

  def perform(*args)
    super(**args)
    tenant = Tenant.find(args[:t_id])
    if tenant
      tenant.background_jobs.destroy_all
      tenant.calendars.destroy_all
      tenant.calls.destroy_all
      tenant.customers.destroy_all
      tenant.dashboards.destroy_all
      tenant.events.destroy_all
      tenant.filters.destroy_all
      tenant.invoice.destroy_all
      tenant.invoice_items.destroy_all
      tenant.locations.destroy_all
      tenant.products.destroy_all
      tenant.projects.destroy_all
      tenant.provided_services.destroy_all
      tenant.punch_cards.destroy_all
      tenant.punch_clocks.destroy_all
      tenant.punches.destroy_all
      tenant.settings.destroy_all
      tenant.teams.destroy_all
      tenant.users.destroy_all

      tenant.users.each do |user|
        user.mugshot.purge if user.mugshot.attached?
        user.user_invitations.destroy_all
        user.time_materials.destroy_all
        user.notifications.destroy_all
      end

      tenant.logo.purge if tenant.logo.attached?
      tenant.destroy!
    end
  end
end
