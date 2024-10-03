class ProvidedServicesController < MortimerController
  # before_action :set_provided_service, only: %i[ show edit update destroy ]

  # # GET /provided_services or /provided_services.json
  # def index
  #   @provided_services = ProvidedService.all
  # end

  # # GET /provided_services/1 or /provided_services/1.json
  # def show
  # end

  # # GET /provided_services/new
  # def new
  #   @provided_service = ProvidedService.new
  # end

  # # GET /provided_services/1/edit
  # def edit
  # end

  # # POST /provided_services or /provided_services.json
  # def create
  #   @provided_service = ProvidedService.new(provided_service_params)

  #   respond_to do |format|
  #     if @provided_service.save
  #       format.html { redirect_to provided_service_url(@provided_service), notice: "Provided service was successfully created." }
  #       format.json { render :show, status: :created, location: @provided_service }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @provided_service.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /provided_services/1 or /provided_services/1.json
  # def update
  #   respond_to do |format|
  #     if @provided_service.update(provided_service_params)
  #       format.html { redirect_to provided_service_url(@provided_service), notice: "Provided service was successfully updated." }
  #       format.json { render :show, status: :ok, location: @provided_service }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @provided_service.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /provided_services/1 or /provided_services/1.json
  # def destroy
  #   @provided_service.destroy!

  #   respond_to do |format|
  #     format.html { redirect_to provided_services_url, notice: "Provided service was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_provided_service
    #   @provided_service = ProvidedService.find(params[:id])
    # end

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:provided_service).permit(:tenant_id, :authorized_by_id, :name, :service, :service_params)
    end
end
