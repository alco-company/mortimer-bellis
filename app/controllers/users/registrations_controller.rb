# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include Authentication
  include TimezoneLocale
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    begin
      usr = nil
      params[:user][:tenant_id] = 1 # temporary placeholder - UserRegistrationService will fix!
      params[:user][:team_id] = 1   # temporary placeholder - UserRegistrationService will fix!
      # configure_sign_up_params
      super do |resource|
        if resource.valid?
          raise "user was not registered correctly" unless UserRegistrationService.call(resource, tenant_name)
          resource.add_role
          usr = resource.dup
        end
      end
    rescue => e
      UserMailer.error_report(e.to_s, "Users::RegistrationController#create - failed for email #{usr&.email}").deliver_later
      usr.destroy unless usr.nil?
      redirect_to root_path, alert: I18n.t("errors.messages.user_registration_failed", error: e.message)
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

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
      redirect_to edit_user_registration_path, alert: I18n.t("errors.messages.user_role_cannot_be_assigned") and return
    end

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      resource.mugshot = mugshot if mugshot && mugshot.attachable?
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      render turbo_stream: [
        turbo_stream.update("form", ""),
        turbo_stream.replace("flash_container", partial: "application/flash_message")
      ]

      # bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

      # respond_with resource, location: after_update_path_for(resource)
    else
      resource.attachment_changes.each do |_, change|
        if change.is_a?(ActiveStorage::Attached::Changes::CreateOne)
          change.upload
          change.blob.save
        end
        # TODO: ActiveStorage::Attached::Changes::CreateMany
      end

      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
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
    params[:password].blank? && params[:password_confirmation].blank? ? update_now(resource, params) : super
  end

  def update_now(resource, params)
    resize_before_save(params[:mugshot], 100, 100)
    unless Current.user.user?
      resource.update role: params[:role] if params[:role].present?
      resource.update global_queries: params[:global_queries] if params[:global_queries].present?
      resource.update tenant_id: params[:tenant_id] if params[:tenant_id].present?
    end
    resource.update name: params[:name],
      mugshot: params[:mugshot],
      pincode: params[:pincode],
      locale: params[:locale],
      time_zone: params[:time_zone]
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :tenant_id, :team_id, :role ])
  end

  #
  # a_waffle_23_company_com - random company name generator by AHD 19/6/2024
  #
  def tenant_name
    sign_up_params[:email]
    # sign_up_params[:email].split("@")[1].split(".")[..-2].join(" ").capitalize
  rescue
    "Unknown Tenant Name"
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :tenant_id, :team_id, :global_queries, :name, :pincode, :mugshot, :locale, :time_zone ])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    # super(resource)
    "/users/sign_in_success"
  end

  # The path used after sign up for inactive tenants.
  def after_inactive_sign_up_path_for(resource)
    # super(resource)
    "/users/sign_in_success"
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
end

#
# TODO - fit mugshot
#
# require 'mini_magick'
# require 'opencv'

# def process_avatar(image_path)
#   # Load the image
#   image = MiniMagick::Image.open(image_path)

#   # Face detection
#   detector = OpenCV::CvHaarClassifierCascade::load('haarcascade_frontalface_default.xml')
#   img = OpenCV::CvMat.load(image_path)
#   faces = detector.detect_objects(img)

#   if faces.any?
#     face = faces.first
#     face_x, face_y, face_width, face_height = face.top_left.x, face.top_left.y, face.width, face.height

#     # Crop the image to the detected face
#     image.crop("#{face_width}x#{face_height}+#{face_x}+#{face_y}")

#     # Resize the image
#     image.resize "150x150"

#     # Compress the image
#     image.quality "80"

#     # Save the processed image
#     image.write "processed_avatar.jpg"
#   end
# end
