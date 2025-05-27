#
# the registration controller for users
# is solely for the Current.user themselves
#
class Users::RegistrationsController < MortimerController
  before_action :resize_mugshot, only: [ :create, :update ]
  # verify_turnstile_request only: %i[create]

  # GET /resource/edit
  def edit
    @resource = resource.persisted? ? resource : Current.user
    super
  end

  # PUT /resource
  #
  # rewriting update method to allow for turbo drive/stream update
  #
  def update
    @resource = Current.user
    if params[:user][:role].present? &&
      !Current.user.superadmin? &&
      [ 0, "0", "superadmin", "Superadmin", "SUPERADMIN" ].include?(params[:user][:role])
      redirect_to edit_users_registrations_url(resource), alert: I18n.t("errors.messages.user_role_cannot_be_assigned") and return
    end

    # self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    # prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource_updated = update_resource(resource, user_params)
    # yield resource if block_given?
    if resource_updated
      resource.mugshot = params[:user][:mugshot] if params[:user][:mugshot].present?
      resource.save
      # set_flash_message_for_update(resource, prev_unconfirmed_email)
      flash[:notice] = I18n.t("users.registrations.updated")
      render turbo_stream: [
        turbo_stream.update("form", ""),
        turbo_stream.replace("profile_dropmenu", ProfileDropmenuComponent.new),
        turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
      ]
      flash.clear
    else
      resource.attachment_changes.each do |_, change|
        if change.is_a?(ActiveStorage::Attached::Changes::CreateOne)
          change.upload
          change.blob.save
        end
        # TODO: ActiveStorage::Attached::Changes::CreateMany
      end

      clean_up_passwords resource
      # set_minimum_password_length
      flash.now[:warning] = t(".validation_errors")
      render turbo_stream: [
        turbo_stream.update("form", partial: "application/edit", locals: { resource: resource }),
        turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
      ]
      flash.clear
    end
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

  def update_resource(resource, params)
    # params[:password].blank? && params[:password_confirmation].blank? ?
    update_now(resource, params)
    #  : update_access(resource, params)
  end

  def update_access(resource, params)
    usr = User.authenticate_by(email: resource.email, password: params[:current_password])
    return unless usr
    params.delete :current_password

    resource.update(params)
  end

  def update_now(resource, params)
    # resize_before_save(params[:mugshot], 100, 100)
    unless Current.user.user?
      # resource.update role: params[:role] if params[:role].present?
      resource.update global_queries: params[:global_queries] if params[:global_queries].present?
      resource.update tenant_id: params[:tenant_id] if params[:tenant_id].present?
    end
    resource.update name: params[:name],
      # mugshot: params[:mugshot],
      pincode: params[:pincode],
      locale: params[:locale],
      time_zone: params[:time_zone]
      Current.user.reload
  end

  #
  # a_waffle_23_company_com - random company name generator by AHD 19/6/2024
  #
  def tenant_name
    user_params[:email]
    # sign_up_params[:email].split("@")[1].split(".")[..-2].join(" ").capitalize
  rescue
    "Unknown Tenant Name"
  end

  private
    def user_params
      params.expect(user: [ :tenant_id, :global_queries, :name, :pincode, :email, :mugshot, :locale, :time_zone, :password, :password_confirmation, :current_password ])
    end

    def clean_up_passwords(resource)
      resource.password = resource.password_confirmation = nil
    end

    def resize_mugshot
      return unless params[:user][:mugshot].present?
      resize_before_save(params[:user][:mugshot], 40, 80)
    end
end
