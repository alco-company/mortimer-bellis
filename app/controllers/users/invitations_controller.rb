class Users::InvitationsController < MortimerController
  skip_before_action :require_authentication, only: [ :edit ]

  def new
  end

  def create
    msg = invite_params[:invitation_message]
    count = 0
    invite_params[:invitees].split(" ").each do |invitee|
      invitee_user = User.new email: invitee, tenant: Current.user.tenant, password: SecureRandom.hex(8), locale: Current.user.locale, time_zone: Current.user.time_zone, invited_by: Current.user, invitation_sent_at: Time.now
      if invitee_user.valid? && invitee_user.save
        Current.user.update invitations_count: Current.user.invitations_count + 1
        UserMailer.invitation_instructions(invitee_user, Current.user, msg).deliver_later
        flash[:info] = I18n.t("devise.invitations.send_instructions", email: invitee)
        invitee_user.invited!
        count += 1
      else
        flash[:alert] = I18n.t("devise.failure.invitation_failed", invitee: invitee)
      end
      Broadcasters::Resource.new(Current.user, stream: "%s_%s_%s" % [ Current.tenant.id, "new_invitation", Current.user.id ]).flash
    end

    flash[:info] = I18n.t("devise.invitations.send_instructions_count", count: count)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: [
        turbo_stream.replace("#{Current.tenant.id}_new_invitations", partial: "users/invitations/new", locals: { resource: User.new, resource_class: User, resource_name: "user" }),
        turbo_stream.replace("flash_container", partial: "application/flash_message")
      ] }
      format.html         { render :new }
    end
  end

  def edit
    @user = User.find_by(invitation_token: params[:token])
    if @user
      @user.confirm!
      @user.confirmed!
      @user.update invitation_accepted_at: Time.now
    end

    if @user&.confirmed?
      redirect_to edit_users_password_url(@user.password_reset_token)
    else
      render :new, alert: "Error accepting invitation. Please try again."
    end
  end

  private
    def invite_params
      params.expect(user: [ :invitees, :invitation_message ])
    end
end
