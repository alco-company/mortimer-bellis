class BackgroundJobsController < MortimerController
  before_action :authorize

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:background_job).permit(:id, :account_id, :user_id, :state, :job_klass, :params, :schedule, :next_run_at, :job_id)
    end

    def authorize
      redirect_to root_path, alert: "fejl" unless current_user.superadmin?
    end
end

# before_action :set_background_job, only: %i[ show edit update destroy ]

# # GET /background_jobs or /background_jobs.json
# def index
#   @background_jobs = BackgroundJob.all
# end

# # GET /background_jobs/1 or /background_jobs/1.json
# def show
# end

# # GET /background_jobs/new
# def new
#   @background_job = BackgroundJob.new
# end

# # GET /background_jobs/1/edit
# def edit
# end

# # POST /background_jobs or /background_jobs.json
# def create
#   @background_job = BackgroundJob.new(background_job_params)

#   respond_to do |format|
#     if @background_job.save
#       format.html { redirect_to background_job_url(@background_job), notice: "Background job was successfully created." }
#       format.json { render :show, status: :created, location: @background_job }
#     else
#       format.html { render :new, status: :unprocessable_entity }
#       format.json { render json: @background_job.errors, status: :unprocessable_entity }
#     end
#   end
# end

# # PATCH/PUT /background_jobs/1 or /background_jobs/1.json
# def update
#   respond_to do |format|
#     if @background_job.update(background_job_params)
#       format.html { redirect_to background_job_url(@background_job), notice: "Background job was successfully updated." }
#       format.json { render :show, status: :ok, location: @background_job }
#     else
#       format.html { render :edit, status: :unprocessable_entity }
#       format.json { render json: @background_job.errors, status: :unprocessable_entity }
#     end
#   end
# end

# # DELETE /background_jobs/1 or /background_jobs/1.json
# def destroy
#   @background_job.destroy!

#   respond_to do |format|
#     format.html { redirect_to background_jobs_url, notice: "Background job was successfully destroyed." }
#     format.json { head :no_content }
#   end
# end

# private
#   # Use callbacks to share common setup or constraints between actions.
#   def set_background_job
#     @background_job = BackgroundJob.find(params[:id])
#   end

#   # Only allow a list of trusted parameters through.
#   def background_job_params
#     params.require(:background_job).permit(:account_id, :user_id, :state, :job_klass, :params, :schedule, :next_run_at, :job_id)
#   end
