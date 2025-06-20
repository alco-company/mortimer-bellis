class UsersController < MortimerController
  skip_before_action :require_authentication, only: [ :sign_in_success ]
  skip_before_action :authorize, only: [ :sign_in_success ]

  # POST /users/:id/archive
  def archive
    @resource = User.find(params[:id])
    if @resource
      @resource.archived? ?
        (@resource.update(state: :out) && notice = t("users.unarchived")) :
        (@resource.archived! && notice = t("users.archived"))
      redirect_back(fallback_location: root_path, notice: notice)
      Broadcasters::Resource.new(@resource, params.permit!).replace
    else
      redirect_back(fallback_location: root_path, warning: t("users.not_found"))
    end
  end

  def sign_in_success
  end

  def create
    resize_before_save(params[:user][:mugshot], 100, 100)
    super
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
      Broadcasters::Resource.new(@resource, params.permit!).replace
    else
      redirect_back(fallback_location: root_path, warning: t("users.not_found"))
    end
  end

  def destroy
    @resource = User.find(params[:id])
    if @resource
      if @resource.remove
        redirect_to users_url, notice: t("users.destroyed")
        Broadcasters::Resource.new(@resource).destroy
      else
        redirect_back(fallback_location: root_path, warning: t("users.not_destroyed"))
      end
    else
      redirect_back(fallback_location: root_path, warning: t("users.not_found"))
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(user: [ :tenant_id, :name, :pincode, :hourly_rate, :email, :role, :mugshot, :locale, :time_zone, :team_id ])
    end

    def resource_create
      if resource_params[:hourly_rate].present?
        resource.hourly_rate = resource_params[:hourly_rate].gsub(",", ".")
      else
        resource.hourly_rate = 0.0
      end
      resource.save
    end

    # after the fact clean-ups
    def create_callback
      params[:user].delete(:mugshot)
      true
    end

    def before_update_callback
      if resource_params[:hourly_rate].present?
        params[:user][:hourly_rate] = resource_params[:hourly_rate].gsub(",", ".")
      else
        params[:user][:hourly_rate] = 0.0
      end
      true
    end

    # after the fact clean-ups
    def update_callback
      params[:user].delete(:mugshot)
      true
    end
end
