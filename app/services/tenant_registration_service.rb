class TenantRegistrationService
  attr_reader :destroy

  #
  #
  #
  def self.call(tenant, user_params, destroy: false)
    @destroy = destroy
    return remove(tenant) if destroy

    if tenant.persisted?
      user = User.new tenant_id: tenant.id, email: user_params[:email], role: "admin", password: user_params[:password], locale: "da", time_zone: "Europe/Copenhagen"
      if user.save
        user.send_confirmation_instructions
        UserMailer.with(user: user).welcome.deliver_later # tell monitor@alco.dk that this user has registered
        create_defaults_for_new tenant, user
        return user
      end
    end
    false
  rescue => e
    UserMailer.error_report(e.to_s, "TenantRegistrationService#call - failed for #{tenant&.id} - destroy: #{@destroy ? 'yes' : 'no'}").deliver_later
  end

  def self.remove(tenant)
    if tenant.persisted?
      UserMailer.with(user: tenant.users.first).last_farewell.deliver_later if tenant.users.any?
      KillTenantJob.perform_later(tenant: Current.tenant, user: Current.user, t_id: tenant.id)
      # KillTenantJob.perform_now(tenant: Current.tenant, user: Current.user, t_id: tenant.id)
      return true
    end
    false
  rescue => e
    UserMailer.error_report(e.to_s, "TenantRegistrationService#call - failed for #{tenant&.id} - destroy: #{@destroy ? 'yes' : 'no'}").deliver_later
  end

  def self.create_defaults_for_new(tenant, user)
    team = Team.find_or_create_by tenant: user.tenant, name: I18n.t("teams.default_team")
    user.update team: team
    #
    location = Location.find_or_create_by tenant: user.tenant, name: I18n.t("locations.default_location")
    PunchClock.find_or_create_by tenant: tenant, name: I18n.t("punch_clocks.user_device_punch_clock"), location: location
    PunchClock.find_or_create_by tenant: tenant, name: I18n.t("punch_clocks.default_punch_clock"), location: location
    #
    Setting.create_defaults_for_new tenant
    #
    Product.create_defaults_for_new tenant
  end
end
