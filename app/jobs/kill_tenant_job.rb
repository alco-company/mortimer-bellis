class KillTenantJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    tenant = Tenant.find(args[:t_id])
    if tenant
      Tenant.transaction do
        step = 1
        tenant.background_jobs.destroy_all
        step += 1
        tenant.batches.destroy_all
        step += 1
        tenant.events.destroy_all
        step += 1
        tenant.calendars.destroy_all
        step += 1
        tenant.calls.destroy_all
        step += 1
        tenant.dashboards.destroy_all
        step += 1
        tenant.filters.destroy_all
        step += 1
        tenant.projects.destroy_all
        step += 1
        tenant.products.destroy_all
        step += 1
        tenant.invoice_items.destroy_all
        step += 1
        tenant.invoices.destroy_all
        step += 1
        tenant.tasks.destroy_all
        step += 1
        tenant.time_materials.destroy_all
        step += 1
        tenant.customers.destroy_all
        step += 1
        tenant.punch_cards.destroy_all
        step += 1
        tenant.punch_clocks.destroy_all
        step += 1
        tenant.punches.destroy_all
        step += 1
        tenant.locations.destroy_all
        step += 1
        tenant.provided_services.destroy_all
        step += 1
        tenant.settings.destroy_all
        step += 1

        tmpstep = step
        tenant.users.each do |user|
          next if user.id == 1
          step = "#{user.id} #{tmpstep} 1"
          user.mugshot.purge if user.mugshot.attached?
          step = "#{user.id} #{tmpstep} 2"
          user.access_grants.destroy_all
          step = "#{user.id} #{tmpstep} 3"
          user.access_tokens.destroy_all
          step = "#{user.id} #{tmpstep} 4"
          user.notifications.destroy_all
          step = "#{user.id} #{tmpstep} 5"
          user.web_push_subscriptions.destroy_all
          step = "#{user.id} #{tmpstep} 6"
          user.sessions.destroy_all
          step = "#{user.id} #{tmpstep} 7"
          user.delete
        end

        step = tmpstep
        step += 1
        tenant.teams.destroy_all
        step += 1
        tenant.logo.purge if tenant.logo.attached?
        step += 1
        tenant.delete
      rescue SQLite3::ConstraintException => e
        Rails.logger.error "Failed to delete tenant #{step} #{tenant.id}: #{e.message}"
      end
    end
  end
end
