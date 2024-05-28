class Users::InvitationsController < Devise::InvitationsController
  include Authentication

  before_action :configure_permitted_parameters
  skip_before_action :ensure_accounted_user, only: [ :edit, :update ]

  private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:invite, keys: [ :account_id, :locale, :time_zone])
    end

    def after_invite_path_for(inviter, invitee = nil)
      users_url
    end
end
