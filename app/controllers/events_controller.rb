class EventsController < MortimerController
  def new
    @resource.calendar = parent
    @resource.account = parent.account
    @resource.from_date = Date.today
    @resource.from_time = Time.now
    @resource.to_date = Date.today
    @resource.to_time = Time.now + 1.hour
    @resource.duration = "1:00"
    @resource.auto_punch = false
    @resource.event_metum = EventMetum.new
    super
  end

  def edit
    @resource.event_metum = @resource.event_metum || EventMetum.new
    super
  end

  # <ActionController::Parameters {"authenticity_token"=>"Q99dYByTHh4flkpVUjL1nGycW5rroXovHMb4VET_KK7pG-fUeI1YpBhtBIUhK_Hrgw6BSlkZDcj4f7lceZBaow",
  # "event"=>#<ActionController::Parameters {
  # "calendar_id"=>"6",
  # "account_id"=>"25",
  # "name"=>"Aftale",
  # "from_date"=>"2024-07-21",
  # "from_time"=>"12:59",
  # "duration"=>"5",
  # "all_day"=>"1",
  # "auto_punch"=>"1",
  # "work_type"=>"in",
  # "break_minutes"=>"45",
  # "daily_interval"=>"1",
  # "days_count"=>"10",
  # "weekly_interval"=>"1",
  # "weeks_count"=>"10",
  # "weekly_weekdays"=> {
  #   "monday"=>"monday",
  #   "tuesday"=>"tuesday",
  #   "wednesday"=>"wednesday",
  #   "thursday"=>"thursday",
  #   "friday"=>"friday",
  #   "saturday"=>"saturday",
  #   "sunday"=>"sunday"
  # },
  # "monthly_days"=>"1,2,3",
  # "monthly_dow"=>"1",
  # "monthly_weekdays"=>{
  #   "monday"=>"monday",
  #   "tuesday"=>"tuesday",
  #   "wednesday"=>"wednesday",
  #   "thursday"=>"thursday",
  #   "friday"=>"friday",
  #   "saturday"=>"saturday",
  #   "sunday"=>"sunday"
  # },
  # "monthly_interval"=>"2",
  # "monthly_count"=>"10",
  # "yearly_interval"=>"1",
  # "monthly_months"=>{
  #   "january"=>"january",
  #   "february"=>"february",
  #   "march"=>"march",
  #   "april"=>"april",
  #   "may"=>"may",
  #   "june"=>"june",
  #   "july"=>"july",
  #   "august"=>"august",
  #   "september"=>"september",
  #   "october"=>"october",
  #   "november"=>"november",
  #   "december"=>"december"
  # },
  # "yearly_dows"=>"1",
  # "yearly_weekdays"=>{
  #   "monday"=>"monday",
  #   "tuesday"=>"tuesday",
  #   "wednesday"=>"wednesday",
  #   "thursday"=>"thursday",
  #   "friday"=>"friday",
  #   "saturday"=>"saturday",
  #   "sunday"=>"sunday"
  # },
  # "years_count"=>"4",
  # "yearly_next_years_start"=>"2026",
  # "comment"=>""
  # } permitted: false>,
  # "punch"=>{"end_date"=>"0204-07-25",
  # "end_time"=>"17:50"},
  # "commit"=>"Opret",
  # "controller"=>"events",
  # "action"=>"create",
  # "calendar_id"=>"6"} permitted: false>
  def create
    super if prepare_resource
  end

  def update
    super if prepare_resource
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_event
    #   @event = Event.find(params[:id])
    # end

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:event).permit(
        :account_id,
        :calendar_id,
        :id,
        :auto_punch,
        :name,
        :from_date,
        :from_time,
        :to_date,
        :to_time,
        :duration,
        :all_day,
        :work_type,
        :break_minutes,
        :break_included,
        :reason,
        :comment,
        :files,
        event_metum_attributes: [
          :daily_interval,
          :days_count,
          :weekly_interval,
          :weeks_count,
          :monthly_days,
          :monthly_dow,
          :yearly_next_years_start,
          :monthly_interval,
          :monthly_count,
          :yearly_interval,
          :yearly_dows,
          :years_count,
          weekly_weekdays: [ :key, :value ],
          monthly_months: [ :key, :value ],
          monthly_weekdays: [ :key, :value ],
          yearly_weekdays: [ :key, :value ]
      ]
      )
    end

    def prepare_resource
      # remove work related settings if auto_punch is disabled
      if resource_params[:auto_punch] == "0"
        params.require(:event).extract!(:work_type, :break_included, :break_minutes, :reason)
      else
        # if no schedule is set
        if no_schedule_set?
          # add a set of punches ([IN|SICK|FREE]/OUT)
          # and forget about persisting the event
          return false
        end
      end
      # if schedule is set
      unless no_schedule_set?
        # else persist the schedule - as an event and an event_metum
        resource.event_metum ||= EventMetum.new
        resource.event_metum.set_rrules(resource_params[:event_metum_attributes])
      end
    end

    def no_schedule_set?
      false # resource_params[:event_metum_attributes].blank?
    end
end

# before_action :set_event, only: %i[ show edit update destroy ]

# # GET /events or /events.json
# def index
#   @events = Event.all
# end

# # GET /events/1 or /events/1.json
# def show
# end

# # GET /events/new
# def new
#   @event = Event.new
# end

# # GET /events/1/edit
# def edit
# end

# # POST /events or /events.json
# def create
#   @event = Event.new(event_params)

#   respond_to do |format|
#     if @event.save
#       format.html { redirect_to event_url(@event), notice: "Event was successfully created." }
#       format.json { render :show, status: :created, location: @event }
#     else
#       format.html { render :new, status: :unprocessable_entity }
#       format.json { render json: @event.errors, status: :unprocessable_entity }
#     end
#   end
# end

# # PATCH/PUT /events/1 or /events/1.json
# def update
#   respond_to do |format|
#     if @event.update(event_params)
#       format.html { redirect_to event_url(@event), notice: "Event was successfully updated." }
#       format.json { render :show, status: :ok, location: @event }
#     else
#       format.html { render :edit, status: :unprocessable_entity }
#       format.json { render json: @event.errors, status: :unprocessable_entity }
#     end
#   end
# end

# # DELETE /events/1 or /events/1.json
# def destroy
#   @event.destroy!

#   respond_to do |format|
#     format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
#     format.json { head :no_content }
#   end
# end
