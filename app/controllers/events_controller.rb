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

  # <ActionController::Parameters: {
  #   "authenticity_token"=>"[FILTERED]",
  #   "event"=>{
  #     "calendar_id"=>"6",
  #     "account_id"=>"25",
  #     "name"=>"Aftale",
  #     "from_date"=>"2024-08-07",
  #     "from_time"=>"12:20",
  #     "to_date"=>"2024-08-07",
  #     "to_time"=>"13:20",
  #     "duration"=>"",
  #     "all_day"=>"on",
  #     "auto_punch"=>"1",
  #     "work_type"=>"free",
  #     "break_minutes"=>"",
  #     "reason"=>"unpaid_free",
  #     "event_metum_attributes"=> {
  #       "daily_interval"=>"1",
  #       "days_count"=>"15",
  #       "weekly_interval"=>"2",
  #       "weeks_count"=>"10",
  #       "weekly_weekdays"=> {
  #         "monday"=>"monday",
  #         "thursday"=>"thursday",
  #         "sunday"=>"sunday"
  #       },
  #       "monthly_days"=>"1,15,20",
  #       "monthly_dow"=>"2",
  #       "monthly_weekdays"=>{
  #         "monday"=>"monday",
  #         "tuesday"=>"tuesday"
  #       },
  #       "monthly_interval"=>"1",
  #       "months_count"=>"15",
  #       "yearly_interval"=>"2",
  #       "monthly_months"=>{
  #         "january"=>"january",
  #         "june"=>"june",
  #         "october"=>"october",
  #         "december"=>"december"
  #       },
  #       "yearly_dows"=>"1",
  #       "yearly_weekdays"=>{
  #         "monday"=>"monday",
  #         "wednesday"=>"wednesday"
  #       },
  #       "years_count"=>"4",
  #       "yearly_next_years_start"=>"2023"
  #     },
  #     "comment"=>""
  #   },
  #   "commit"=>"Opret",
  #   "calendar_id"=>"6"
  # } permitted: false>
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
        :breaks_included,
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
          :months_count,
          :yearly_interval,
          :yearly_dows,
          :years_count,
          weekly_weekdays: [
            :monday,
            :tuesday,
            :wednesday,
            :thursday,
            :friday,
            :saturday,
            :sunday
          ],
          monthly_weekdays: [
            :monday,
            :tuesday,
            :wednesday,
            :thursday,
            :friday,
            :saturday,
            :sunday
          ],
          yearly_weekdays: [
            :monday,
            :tuesday,
            :wednesday,
            :thursday,
            :friday,
            :saturday,
            :sunday
          ],
          yearly_months: [
            :january,
            :february,
            :march,
            :april,
            :may,
            :june,
            :july,
            :august,
            :september,
            :october,
            :november,
            :december
          ]
        ]
      )
    end

    def prepare_resource
      # is this a work related event?
      if resource_params[:auto_punch] == "0"
        params.require(:event).extract!(:work_type, :breaks_included, :break_minutes, :reason)
      else
        # if this is not about 'scheduling' a work event, ie. it's about setting a set of punch in/out's
        if no_schedule_set?
          # add a set of punches ([IN|SICK|FREE]/OUT)
          # and forget about persisting the event
          return false
        end
      end
      # if a schedule is set
      unless no_schedule_set?
        # else persist the schedule - as an event and an event_metum
        resource.event_metum ||= EventMetum.new
        resource.event_metum.set_rrules(resource_params[:event_metum_attributes])
      end
      true
    end

    def no_schedule_set?
      resource_params[:event_metum_attributes].to_h == {
        "daily_interval"=>"",
        "days_count"=>"",
        "weekly_interval"=>"",
        "weeks_count"=>"",
        "monthly_days"=>"",
        "monthly_dow"=>"",
        "yearly_next_years_start"=>"",
        "monthly_interval"=>"",
        "months_count"=>"",
        "yearly_interval"=>"",
        "yearly_dows"=>"",
        "years_count"=>""
      }
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
