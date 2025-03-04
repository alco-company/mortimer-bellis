#
# the registration controller for users
# is solely for the Current.user themselves
#
class Users::RegistrationsController < MortimerController
  # allow_unauthenticated_access only: %i[new create]
  # resume_session only: :new

  # def new
  #   @user = User.new
  # end

  # def create
  #   begin
  #     usr = nil
  #     params[:user][:tenant_id] = 1 # temporary placeholder - UserRegistrationService will fix!
  #     params[:user][:team_id] = 1   # temporary placeholder - UserRegistrationService will fix!
  #     resource = User.new(user_params)
  #     if resource.save
  #       raise "user was not registered correctly" unless UserRegistrationService.call(resource, tenant_name)
  #       resource.add_role
  #       usr = resource.dup
  #       flash[:notice] = I18n.t("devise.registrations.signed_up_but_unconfirmed")
  #       # , alert: "<span>Your account is not confirmed.<span> #{view_context.link_to("Resend confirmation email?", new_confirmation_url(email: user.email), class: "underline text-sky-500")}".html_safe
  #       respond_to do |format|
  #         format.turbo_stream { render turbo_stream: [
  #           turbo_stream.replace("new_registration", partial: "users/sessions/new", locals: { resource: User.new, resource_class: User, resource_name: "user" }),
  #           turbo_stream.replace("flash_container", partial: "application/flash_message")
  #         ] }
  #         format.html         { redirect_to new_users_session_url }
  #       end
  #     else
  #       flash[:alert] = I18n.t("devise.registrations.failed")
  #       # , alert: "<span>Your account is not confirmed.<span> #{view_context.link_to("Resend confirmation email?", new_confirmation_url(email: user.email), class: "underline text-sky-500")}".html_safe
  #       respond_to do |format|
  #         format.turbo_stream { render turbo_stream: [
  #           turbo_stream.replace("new_registration", partial: "users/registrations/new", locals: { resource: User.new, resource_class: User, resource_name: "user" }),
  #           turbo_stream.replace("flash_container", partial: "application/flash_message")
  #         ] }
  #         format.html         { redirect_to new_users_session_url }
  #       end
  #     end
  #   rescue => e
  #     UserMailer.error_report(e.to_s, "Users::RegistrationController#create - failed for email #{usr&.email}").deliver_later
  #     usr.destroy unless usr.nil?
  #     redirect_to root_path, alert: I18n.t("errors.messages.user_registration_failed", error: e.message)
  #   end
  # end

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
    unless params[:user][:mugshot].present?
      mugshot = resource.mugshot
    end
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
      resource.mugshot = mugshot if mugshot && mugshot.attachable?
      # set_flash_message_for_update(resource, prev_unconfirmed_email)
      flash[:notice] = I18n.t("users.registrations.updated")
      render turbo_stream: [
        turbo_stream.update("form", ""),
        turbo_stream.replace("profile_dropmenu", ProfileDropmenuComponent.new),
        turbo_stream.replace("flash_container", partial: "application/flash_message")
      ]
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
        turbo_stream.update("form", partial: "users/registrations/edit", locals: { resource: resource }),
        turbo_stream.replace("flash_container", partial: "application/flash_message")
      ]

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
    params[:password].blank? && params[:password_confirmation].blank? ? update_now(resource, params) : update_access(resource, params)
  end

  def update_access(resource, params)
    usr = User.authenticate_by(email: resource.email, password: params[:current_password])
    return unless usr
    params.delete :current_password

    resource.update(params)
  end

  def update_now(resource, params)
    resize_before_save(params[:mugshot], 100, 100)
    unless Current.user.user?
      # resource.update role: params[:role] if params[:role].present?
      resource.update global_queries: params[:global_queries] if params[:global_queries].present?
      resource.update tenant_id: params[:tenant_id] if params[:tenant_id].present?
    end
    resource.update name: params[:name],
      mugshot: params[:mugshot],
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

  def resize_before_save(image_param, width, height)
    return unless image_param

    begin
      ImageProcessing::MiniMagick
        .source(image_param)
        .resize_to_fit(width, height)
        .call(destination: image_param.tempfile.path)
    rescue StandardError => _e
      # Do nothing. If this is catching, it probably means the
      # file type is incorrect, which can be caught later by
      # model validations.
    end
  end

  private
    def user_params
      params.expect(user: [ :tenant_id, :global_queries, :name, :pincode, :email, :mugshot, :locale, :time_zone, :password, :password_confirmation, :current_password ])
    end

    def clean_up_passwords(resource)
      resource.password = resource.password_confirmation = nil
    end
end
