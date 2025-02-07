# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  include TimezoneLocale
  # GET /resource/password/new
  # def new
  #   super
  # end

  def edit
    self.resource = resource_class.new
    set_minimum_password_length
    resource.reset_password_token = params[:reset_password_token]
    flash[:notice] = I18n.t("devise.passwords.update_now")
  end

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      flash[:notice] = I18n.t("devise.passwords.send_instructions")
      respond_to do |format|
        format.turbo_stream { render turbo_stream: [
          turbo_stream.replace("new_password", partial: "users/sessions/new", locals: { resource: User.new, resource_class: User, resource_name: "user" }),
          turbo_stream.replace("flash_container", partial: "application/flash_message")
        ] }
        format.html         { redirect_to root_path }
      end
    else
      respond_with(resource)
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
