class PunchClocksController < MortimerController
  def show
    @punch_pagy, @punch_records = pagy(@resource.punches)
    super
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(punch_clock: [ :tenant_id, :location_id, :name, :ip_addr, :last_punched_at, :access_token, :locale, :time_zone ])
    end
end
