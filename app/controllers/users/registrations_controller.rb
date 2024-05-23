# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include Authentication
  # before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [ :update ]
  skip_before_action :authenticate_user!, only: [ :new, :create ]
  skip_before_action :ensure_accounted_user, only: [ :new, :create ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    params[:user][:account_id] = Account.find_or_create_by(name: account_name, email: sign_up_params[:email]).id
    configure_sign_up_params
    super do |resource|
      resource.add_role
      UserRegistrationService.call(resource)
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    if params[:user][:role].present? &&
      !Current.user.superadmin? &&
      [ 0, "0", "superadmin", "Superadmin", "SUPERADMIN" ].include?(params[:user][:role])
      redirect_to edit_user_registration_path, alert: "You are not authorized to change the role to superadmin." and return
    end
    super
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :account_id, :role ])
  end

  def account_name
    sign_up_params[:email].split("@")[1].split(".")[..-2].join(" ").capitalize
  rescue
    "Unknown Account Name"
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :account_id, :global_queries, :name, :mugshot, :locale, :time_zone ])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
