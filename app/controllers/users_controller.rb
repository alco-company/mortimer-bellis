class UsersController < MortimerController
  before_action :authorize
  skip_before_action :authenticate_user!, only: [ :sign_in_success ]
  skip_before_action :ensure_tenanted_user, only: [ :sign_in_success ]
  skip_before_action :authorize, only: [ :sign_in_success ]

  # before_action lambda {
  #   resize_before_save(resource_params[:mugshot], 100, 100)
  # }, only: [ :update ]

  # POST /users/:id/archive
  def archive
    @resource = User.find(params[:id])
    if @resource
      @resource.archived? ?
        (@resource.update(state: :out) && notice = t("users.unarchived")) :
        (@resource.archived! && notice = t("users.archived"))
      redirect_back(fallback_location: root_path, notice: notice)
      Broadcasters::Resource.new(@resource).replace
    else
      redirect_back(fallback_location: root_path, warning: t("users.not_found"))
    end
  end

  def sign_in_success
  end

  def update
    if params[:user][:role].present? &&
      !Current.user.superadmin? &&
      [ 0, "0", "superadmin", "Superadmin", "SUPERADMIN" ].include?(params[:user][:role])
      redirect_to edit_resource_url, error: t(:cannot_change_role) and return
    end
    resize_before_save(params[:user][:mugshot], 100, 100)
    super
  end

  # POST /users/:id/archive
  def archive
    @resource = User.find(params[:id])
    if @resource
      @resource.archived? ?
        (@resource.update(state: :out) && notice = t("users.unarchived")) :
        (@resource.archived! && notice = t("users.archived"))
      redirect_back(fallback_location: root_path, notice: notice)
      Broadcasters::Resource.new(@resource).replace
    else
      redirect_back(fallback_location: root_path, warning: t("users.not_found"))
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:user).permit(:tenant_id, :name, :pincode, :email, :role, :mugshot, :locale, :time_zone)
    end

    def update_callback(_u)
      params[:user].delete(:mugshot)
    end

    def authorize
      redirect_to(root_path, alert: t(:unauthorized)) if current_user.user?
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
