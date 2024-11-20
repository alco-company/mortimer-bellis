class Users::InvitationsController < Devise::InvitationsController
  include Authentication
  include TimezoneLocale

  before_action :configure_permitted_parameters
  skip_before_action :ensure_tenanted_user, only: [ :edit, :update ]
  skip_before_action :authenticate_user!, only: [ :edit, :update ]

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
