class EmployeeInvitationsController < MortimerController
  skip_before_action :require_authentication, only: [ :show ]

  def new
    @resource.state = :draft
    super
  end

  def show
    if params[:api_key].present? && params[:api_key] == @resource.access_token
      @resource.update state: :opened, seen_at: DateTime.current
      @inviter = @resource.user.name rescue "not disclosed"
      @user = User.new tenant: @resource.tenant, email: @resource.address, locale: @resource.user.locale, time_zone: @resource.user.time_zone, team: @resource.team, access_token: @resource.access_token
      render "employee_sign_up"
    else
      authenticate_user! || redirect_to(new_user_session_path)
      super
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(user_invitation: [
        :tenant_id,
        :user_id,
        :team_id,
        :state,
        :address,
        :invited_at,
        :seen_at,
        :completed_at
      ])
    end

    #
    # implement on the controller inheriting this concern
    # in order to not having to extend the create method on this concern
    #
    def create_callback
      @resource.address.split(/[ ,;]/).each do |addr|
        resource = UserInvitation.create(
          tenant_id: @resource.tenant_id,
          user_id: @resource.user_id,
          team_id: @resource.team_id,
          address: addr,
          access_token: SecureRandom.hex(16),
          state: :draft
        )
        if resource
          case resource.address
          in /^([^@]+)@(.+)$/; UserMailer.with(invitation: resource, sender: current_user.name).invite.deliver_later
          in /^[0-9]{8}$/; UserSms.new(invitation: resource).invite
          end

          resource.update state: :sent, invited_at: DateTime.current
          Broadcasters::Resource.new(resource).create
        end
      end
      @resource.destroy
    end
end
