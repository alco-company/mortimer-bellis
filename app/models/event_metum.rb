class EventMetum < ApplicationRecord
  belongs_to :event

  attr_accessor :rule, :uivalues

  def rule(from, tz)
    @rule ||= RRule::Rule.new(rrule, dtstart: from, tzid: tz)
  end

  def occurs_on?(date, window, tz)
    rule(window[:from], tz).between(window[:from], window[:to]).map { |e| e.day }.include?(date.to_time.day)
  rescue => error
    say "EventMetum#occurs_on? #{error.message}"
    false
  end

  def uivalues
    @uivalues ||= JSON.parse(ui_values) rescue {}
  end

  def get_field(field)
    uivalues[field.to_s] rescue ""
  end

  # from_params is a hash of values from the UI
  # tz is the timezone of the user - eg Time.zone or Time.find_zone("Moscow")
  #
  # either return a new RRule object or false
  #
  # :daily_interval,
  # :days_count,
  # :weekly_interval,
  # :weeks_count,
  # :monthly_days,
  # :monthly_dow,
  # :yearly_next_years_start,
  # :monthly_interval,
  # :monthly_count,
  # :yearly_interval,
  # :yearly_dows,
  # :years_count,
  # :weekly_weekdays,
  # :monthly_months,
  # :monthly_weekdays,
  # :yearly_weekdays,
  # :daily_interval=,
  # :days_count=,
  # :weekly_interval=,
  # :weeks_count=,
  # :monthly_days=,
  # :monthly_dow=,
  # :yearly_next_years_start=,
  # :monthly_interval=,
  # :months_count=,
  # :yearly_interval=,
  # :yearly_dows=,
  # :years_count=,
  # :weekly_weekdays=,
  # :monthly_months=,
  # :monthly_weekdays=,
  # :yearly_weekdays=,
  #
  def from_params(params: {}, tz: nil)
    return false unless params.is_a?(Hash)
    self.ui_values = params.to_json
    tz = get_time_zone(tz)
    set_rrules(params, tz)
  end

  def set_rrules(params, tz = nil)
    self.rrule = "RRULE:"
    set_daily(params)
    set_weekly(params)
    set_monthly(params)
    set_yearly(params)
    RRuleEngine::RRule.validate(self.rrule)
  end

  def set_daily(params)
    self.rrule += "FREQ=DAILY;"                           if params[:daily_interval].present? || params[:days_count].present?
    self.rrule += "INTERVAL=#{params[:daily_interval]};"  if params[:daily_interval].present?
    self.rrule += "COUNT=#{params[:days_count]};"         if params[:days_count].present?
  end

  def get_daily
    @daily_interval, @days_count = RRuleEngine::RRule.daily(self.rrule)
  end

  # # TODO allow for sunday start of week - important to Americans ua.
  def set_weekly(params)
    self.rrule += "FREQ=WEEKLY;WKST=MO;" if params[:weekly_interval].present? || params[:weekly_weekdays].present? || params[:weekly_weeks].present? || params[:weeks_count].present?
    self.rrule += "INTERVAL=#{params[:weekly_interval].to_i};"                                    if params[:weekly_interval].present?
    set_byday(params)                                                                             if params[:weekly_weekdays].present?
    self.rrule += "BYWEEKNO=#{params[:weekly_weeks].join(',')};"                                  if params[:weekly_weeks].present?
    self.rrule += "COUNT=#{params[:weeks_count]};"                                                if params[:weeks_count].present?
  end

  #
  # BYDAY=1MO, -2TU,WE,TH,FR,SA,SU
  def set_byday(params, freq = :weekly)
    case freq
    when :weekly;   set_byday_rrule(params[:weekly_weekdays]) # self.rrule += "BYDAY=#{params[:weekly_weekdays].keys.map { |d| d.to_s[0..1].upcase }.join(",") };"
    when :monthly
      unless params[:monthly_dow].present?
        set_byday_rrule(params[:monthly_weekdays])
      else
        self.rrule += "BYDAY=#{params[:monthly_weekdays].keys.map { |d| "#{params[:monthly_dow]}%s" % d.to_s[0..1].upcase }.join(",") };"
      end
    when :yearly
      unless params[:yearly_dow].present?
        set_byday_rrule(params[:yearly_weekdays])
      else
        self.rrule += "BYDAY=#{params[:yearly_weekdays].keys.map { |d| set_days(d, params[:yearly_dow]) }.join(",") };"
      end
    end
  end

  def set_byday_rrule(params)
    self.rrule += "BYDAY=#{params.keys.map { |d| d.to_s[0..1].upcase }.join(",") };"
  end

  def set_days(d, dow)
    dow.map { |w| "%s%s" % [ w, d.to_s[0..1].upcase ] }.join(",")
  end

  def set_monthly(params)
    self.rrule += "FREQ=MONTHLY;"                                 if params[:monthly_interval].present? || params[:monthly_days].present? || params[:months_count].present? || params[:monthly_weekdays].present? || params[:monthly_dow].present?
    self.rrule += "INTERVAL=#{params[:monthly_interval].to_i};"   if params[:monthly_interval].present?
    set_byday(params, :monthly)                                   if params[:monthly_weekdays].present? || params[:monthly_dow].present?
    self.rrule += "BYMONTHDAY=#{params[:monthly_days]};"          if params[:monthly_days].present?
    self.rrule += "COUNT=#{params[:months_count]};"               if params[:months_count].present?
  end

  # { yearly_interval: 2, years_count: 3, first_year: 2024, yearly_months: [ 1 ], yearly_dow: [ 1 ] }
  def set_yearly(params)
    self.rrule += "FREQ=YEARLY;" if params[:yearly_interval].present? || params[:yearly_months].present? || params[:years_count].present?
    self.rrule += "INTERVAL=#{params[:yearly_interval].to_i};"                                    if params[:yearly_interval].present?
    set_byday(params, :yearly)                                                                    if params[:yearly_weekdays].present? || params[:yearly_dow].present?
    self.rrule += "BYMONTH=#{ get_month_indexes(params[:yearly_months].keys) };"                  if params[:yearly_months].present?
    self.rrule += "COUNT=#{params[:years_count]};"                                                if params[:years_count].present?
  end

  def get_month_indexes(params)
    im = [ "january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december" ].map.with_index(1).to_h
    mths = []
    params.each do |k|
      mths << im[k]
    end
    mths.join(",")
  end


  def get_time_zone(tz)
    tz = tz.nil? ? Time.zone : Time.find_zone(tz)
    tz.nil? ? Time.zone : tz
  end
end
