class EventService
  attr_accessor :resource, :resource_class, :params

  def initialize(resource:, params:)
    @resource = resource || Event.new(event_metum: EventMetum.new)
    @resource_class = Event
    @params = params
  end

  # 3 outcomes:
  #
  # { ok:    Event   => resource };  # created an event => update calendar
  # { ok:    String => msg };        # punches => flash the string
  # { error: String  => msg };       # validation/other error => return event form with error
  #
  def create
    if prepare_resource
      if self.resource.save
        { ok: self.resource }
      else
        { error: I18n.t("events.create.event_validation_errors") }
      end
    else
      { ok: I18n.t("events.create.punches_created") }
    end
  rescue => error
    { error: error.message }
  end

  #
  # either return true => event was updated
  # or false => event was not updated
  def update
    if prepare_resource
      if self.resource.update(resource_params)
        { ok: self.resource }
      else
        { error: I18n.t("events.update.event_validation_errors") }
      end
    else
      { ok: I18n.t("events.update.punches_created") }
    end
  end

  private

    def prepare_resource
      self.params.require(:event).extract!(:event_metum_attributes) if no_schedule_set?
      #
      # is this a work related event?
      if resource_params[:auto_punch] == "0"
        self.params.require(:event).extract!(:work_type, :breaks_included, :break_minutes, :reason)
      else
        # if this is not about 'scheduling' a work event, ie. it's about setting a set of punch in/out's
        if no_schedule_set?
          # add a set of punches ([IN|SICK|FREE]/OUT)
          # and forget about persisting the event
          return false
        end
      end

      self.resource = self.resource_class.new(resource_params) if self.resource.new_record?

      # if a schedule is set
      unless no_schedule_set?
        # else persist the schedule - as an event and an event_metum
        self.resource.event_metum ||= EventMetum.new
        self.resource.event_metum.set_rrules(resource_params[:event_metum_attributes])
      end
      true
    rescue => error
      debugger
      false
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      self.params.require(:event).permit(
        :tenant_id,
        :calendar_id,
        :id,
        :auto_punch,
        :name,
        :from_date,
        :from_time,
        :to_date,
        :to_time,
        :event_color,
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
          :yearly_doy,
          :yearly_days,
          :years_count,
          :yearly_weeks,
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

    def no_schedule_set?
      resource_params[:event_metum_attributes].nil? ||
      resource_params[:event_metum_attributes].to_h == {
        "daily_interval"=>"",
        "days_count"=>"",
        "weekly_interval"=>"",
        "weeks_count"=>"",
        "monthly_days"=>"",
        "monthly_dow"=>"",
        "monthly_interval"=>"",
        "months_count"=>"",
        "yearly_interval"=>"",
        "yearly_doy"=>"",
        "yearly_days"=>"",
        "yearly_weeks"=>"",
        "yearly_dows"=>"",
        "years_count"=>"",
        "yearly_next_years_start"=>""
      }
    end
end
