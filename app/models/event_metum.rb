class EventMetum < ApplicationRecord
  belongs_to :event

  attr_accessor :rule

  def rule
    @rule ||= RRule.parse(rrule)
  end

  # from_params is a hash of values from the UI
  # tz is the timezone of the user - eg Time.zone or Time.find_zone("Moscow")
  #
  # either return a new RRule object or false
  #
  def from_params(params: {}, tz: nil)
    return false unless params.is_a?(Hash)
    self.ui_values = params.to_json
    tz = get_time_zone(tz)
    build(params, tz)
  end

  def build(params, tz)
    self.rrule = "RRULE:"
    set_daily(params)
    set_weekly(params)
    set_monthly(params)
    set_yearly(params)
    RRuleEngine::RRule.validate(self.rrule)
  end

  def set_daily(params)
    self.rrule += "FREQ=DAILY;" if params[:daily_interval].present? || params[:days_count].present?
    self.rrule += "INTERVAL=#{params[:daily_interval]};"                                          if params[:daily_interval].present?
    self.rrule += "COUNT=#{params[:days_count]};"                                                 if params[:days_count].present?
  end

  # # TODO allow for sunday start of week - important to Americans ua.
  def set_weekly(params)
    self.rrule += "FREQ=WEEKLY;WKSTA=MO;" if params[:weekly_interval].present? || params[:weekly_weekdays].present? || params[:weekly_weeks].present? || params[:weeks_count].present?
    self.rrule += "INTERVAL=#{params[:weekly_interval].to_i};"                                    if params[:weekly_interval].present?
    set_byday(params)                                                                             if params[:weekly_weekdays].present?
    self.rrule += "BYWEEKNO=#{params[:weekly_weeks].join(',')};"                                  if params[:weekly_weeks].present?
    self.rrule += "COUNT=#{params[:weeks_count]};"                                                if params[:weeks_count].present?
  end

  #
  # BYDAY=1MO, -2TU,WE,TH,FR,SA,SU
  def set_byday(params, freq = :weekly)
    case freq
    when :weekly;   self.rrule += "BYDAY=#{params[:weekly_weekdays].map { |d| d.to_s[0..1].upcase }.join(",") };"
    when :monthly
      unless params[:monthly_dow].present?
        params[:weekly_weekdays] = params[:monthly_weekdays]
        set_byday(params)
      else
        self.rrule += "BYDAY=#{params[:monthly_weekdays].map { |d| "#{params[:monthly_dow]}%s" % d.to_s[0..1].upcase }.join(",") };"
      end
    when :yearly
      unless params[:yearly_dow].present?
        params[:weekly_weekdays] = params[:yearly_weekdays]
        set_byday(params)
      else
        self.rrule += "BYDAY=#{params[:yearly_weekdays].map { |d| set_days(d, params[:yearly_dow]) }.join(",") };"
      end
    end
  end

  def set_days(d, dow)
    dow.map { |w| "%s%s" % [ w, d.to_s[0..1].upcase ] }.join(",")
  end

  def set_monthly(params)
    self.rrule += "FREQ=MONTHLY;" if params[:monthly_interval].present? || params[:monthly_days].present? || params[:months_count].present? || params[:monthly_weekdays].present? || params[:monthly_dow].present?
    self.rrule += "INTERVAL=#{params[:monthly_interval].to_i};"                                   if params[:monthly_interval].present?
    set_byday(params, :monthly)                                                                   if params[:monthly_weekdays].present? || params[:monthly_dow].present?
    self.rrule += "BYMONTHDAY=#{params[:monthly_days].join(",")};"                                if params[:monthly_days].present?
    self.rrule += "COUNT=#{params[:months_count]};"                                               if params[:months_count].present?
  end

  # { yearly_interval: 2, years_count: 3, first_year: 2024, yearly_months: [ 1 ], yearly_dow: [ 1 ] }
  def set_yearly(params)
    self.rrule += "FREQ=YEARLY;" if params[:yearly_interval].present? || params[:yearly_months].present? || params[:years_count].present?
    self.rrule += "INTERVAL=#{params[:yearly_interval].to_i};"                                    if params[:yearly_interval].present?
    set_byday(params, :yearly)                                                                    if params[:yearly_weekdays].present? || params[:yearly_dow].present?
    self.rrule += "BYMONTH=#{params[:yearly_months].join(',')};"                                  if params[:yearly_months].present?
    self.rrule += "COUNT=#{params[:years_count]};"                                                if params[:years_count].present?
  end

  def get_time_zone(tz)
    tz = tz.nil? ? Time.zone : Time.find_zone(tz)
    tz.nil? ? Time.zone : tz
  end
end
