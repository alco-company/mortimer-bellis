class SettingsController < MortimerController
  # before_action :set_setting, only: %i[ show edit update destroy ]

  # # GET /settings or /settings.json
  # def index
  #   @settings = Setting.all
  # end

  # # GET /settings/1 or /settings/1.json
  # def show
  # end

  # # GET /settings/new
  # def new
  #   @setting = Setting.new
  # end

  # # GET /settings/1/edit
  # def edit
  # end

  # # POST /settings or /settings.json
  # def create
  #   @setting = Setting.new(setting_params)

  #   respond_to do |format|
  #     if @setting.save
  #       format.html { redirect_to setting_url(@setting), notice: "Setting was successfully created." }
  #       format.json { render :show, status: :created, location: @setting }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @setting.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /settings/1 or /settings/1.json
  # def update
  #   respond_to do |format|
  #     if @setting.update(setting_params)
  #       format.html { redirect_to setting_url(@setting), notice: "Setting was successfully updated." }
  #       format.json { render :show, status: :ok, location: @setting }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @setting.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /settings/1 or /settings/1.json
  # def destroy
  #   @setting.destroy!

  #   respond_to do |format|
  #     format.html { redirect_to settings_url, notice: "Setting was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_setting
    #   @setting = Setting.find(params[:id])
    # end

    # <ActionController::Parameters {
    #   "key"=>"add_comments_on_time_material",
    #   "value"=>"1",
    #   "rc"=>"TimeMaterial",
    #   "rc_id"=>"0",
    #   "target"=>"setting_i_20",
    #   "controller"=>"settings",
    #   "action"=>"create",
    #   "setting"=>
    #     "key"=>"add_comments_on_time_material",
    #     "value"=>"1"
    #     }
    # } permitted: false>
    def before_create_callback
      resource.setable_id = params[:rc_id] if params[:rc_id].present? && params[:rc_id].to_i.positive?
      resource.setable_type = params[:rc] if params[:rc].present?
      resource.valid?
    end

    def create_callback
      params[:type] = resource.type
      Broadcasters::Resource.new(resource, params.permit!, target: params[:target], user: Current.get_user, stream: "#{Current.get_tenant.id}_settings_view", partial: "settings/special").replace
    end

    def before_update_callback
      resource.valid?
    end

    # TimeMaterial => Parameters: {"key"=>"limit_time_to_quarters", "value"=>"1", "id"=>"423", "setting"=>{"key"=>"limit_time_to_quarters", "value"=>"1"}}
    # User => Parameters: {"key"=>"limit_time_to_quarters", "value"=>"0", "id"=>"423", "setting"=>{"key"=>"limit_time_to_quarters", "value"=>"0"}}
    def update_callback
      params[:type] = resource.type
      Broadcasters::Resource.new(resource, params.permit!, target: params[:target], user: Current.get_user, stream: "#{Current.get_tenant.id}_settings_view", partial: "settings/special").replace
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(setting: [ :tenant_id, :setable_id, :setable_type, :key, :priority, :formating, :value ])
    end
end
