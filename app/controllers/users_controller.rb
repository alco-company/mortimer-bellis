class UsersController < MortimerController
  before_action :authorize
  skip_before_action :authenticate_user!, only: [ :sign_in_success ]
  skip_before_action :ensure_tenanted_user, only: [ :sign_in_success ]
  skip_before_action :authorize, only: [ :sign_in_success ]

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
      params.require(:user).permit(:tenant_id, :email, :role, :mugshot, :locale, :time_zone)
    end

    def authorize
      redirect_to(root_path, alert: t(:unauthorized)) if current_user.user?
    end
end
