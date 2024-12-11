class Users::InvitationsController < Devise::InvitationsController
  include Authentication
  include TimezoneLocale
  # include Turbo::StreamsHelper
  # include ActionView::RecordIdentifier

  before_action :configure_permitted_parameters
  skip_before_action :ensure_tenanted_user, only: [ :edit, :update ]
  skip_before_action :authenticate_user!, only: [ :edit, :update ]

  def create
    result = more_invitees? ? invite_more_users : invite_user
    unless result.blank?
      flash[:success] = t("devise.invitations.send_instructions", email: result)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: [
          turbo_stream.replace("new_invitation", partial: "users/invitations/new", locals: { resource: User.new }),
          turbo_stream.replace("flash_container", partial: "application/flash_message")
        ] }
      end
    else
      respond_with(resource)
    end
  end

  def more_invitees?
    params[:user][:email].include?(",") or params[:user][:email].include?(";") or params[:user][:email].include?(" ")
  end

  def invite_more_users
    invitees = params[:user][:email].split("\n").collect { |s| s.split(/,|;| /) }.flatten
    result = []
    stream = "%s_%s_%s" % [ Current.tenant.id, "new_invitation", Current.user.id ]
    while invitees.any?
      params[:user][:email] = invitees.shift
      self.resource = invite_resource
      resource_invited = resource.errors.empty?
      if resource_invited
        result << resource.email
        Turbo::StreamsChannel.broadcast_action_to(
          stream,
          target: "new_invitation",
          action: :replace,
          partial: "users/invitations/new",
          locals: { resource: User.new(email: invitees.compact.join(",")), resource_name: "user", params: {}, user: Current.user }
        )
      end
    end
    result.any? ? result.join(", ") : ""
  end

  def invite_user
    self.resource = invite_resource
    resource_invited = resource.errors.empty?

    yield resource if block_given?

    if resource_invited
      if is_flashing_format? && self.resource.invitation_sent_at
        # set_flash_message :notice, :send_instructions, email: self.resource.email
        flash[:success] = t("devise.invitations.send_instructions", email: self.resource.email)
      end
      # if self.method(:after_invite_path_for).arity == 1
      #   respond_with resource, location: after_invite_path_for(current_inviter)
      # else
      #   respond_with resource, location: after_invite_path_for(current_inviter, resource)
      # end
      resource.email
    else
      ""
    end
  end

  private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:invite, keys: [ :tenant_id, :locale, :time_zone ])
    end

    def after_invite_path_for(inviter, invitee = nil)
      users_url
    end

    # This is called when accepting invitation.
    # It should return an instance of resource class.
    def accept_resource
      resource = resource_class.accept_invitation!(update_resource_params)
      # Report accepting invitation to analytics
      # Analytics.report('invite.accept', resource.id)
      resource
    end

    def after_accept_path_for(resource)
      resource.update name: resource.email
      root_path
    end
end
