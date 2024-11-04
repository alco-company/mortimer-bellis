class TimeMaterialsController < MortimerController
  def new
    super
    @resource.customer_name = TimeMaterial.by_exact_user(Current.user).last&.customer_name
    @resource.date = Time.current.to_date
    @resource.user_id = Current.user.id
  end

  def edit
    @resource.customer_name = @resource.customer&.name unless @resource.customer_id.blank?
    @resource.project_name = @resource.project&.name unless @resource.project_id.blank?
    @resource.product_name = @resource.product&.name unless @resource.product_id.blank?
  end

  # pick up the play button from the time_material#index view
  #
  def create
    params[:play].present? ? create_play : super
  end

  def create_play
    params[:time_material] = { time: "0,25", user_id: Current.user.id, date: Time.current.to_date, about: "current_task" }
    params.delete(:play)
    params[:played] = true
    create
  end

  # POST /users/:id/archive
  def archive
    @resource = TimeMaterial.find(params[:id])
    if @resource
      @resource.archived? ?
        (@resource.pushed_to_erp! && notice = t("time_material.unarchived")) :
        (@resource.archived! && notice = t("time_material.archived"))
      redirect_back(fallback_location: root_path, notice: notice)
      Broadcasters::Resource.new(@resource).replace
    else
      redirect_back(fallback_location: root_path, warning: t("users.not_found"))
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:time_material).permit(
        :tenant_id,
        :date,
        :time,
        :overtime,
        :about,
        :user_id,
        :customer_name,
        :customer_id,
        :project_name,
        :project_id,
        :product_name,
        :product_id,
        :quantity,
        :rate,
        :unit_price,
        :unit,
        :discount,
        :comment,
        :state,
        :is_invoice,
        :is_free,
        :is_offer,
        :is_separate
      )
    end
end
