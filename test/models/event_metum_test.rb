require "test_helper"

class EventMetumTest < ActiveSupport::TestCase
  def setup
    ev = events(:one)
    @em = EventMetum.new(event: ev)
  end

  test "should not save event_metum without event" do
    event_metum = EventMetum.new
    assert_not event_metum.save, true
  end

  test "should save event_metum with account, calendar, and event" do
    assert @em.save, true
  end

  test "event should recur next 15 days" do
    params = { daily_interval: 1, days_count: 15 }
    tm = Time.now.in_time_zone("Moscow")
    @em.from_params(params: params, tz: tm)
    assert @em.save, true
    assert @em.rule.between(tm, tm + 15.days).count == 15, true
  end

  test "event should recur every 2 weeks on wednesday and saturday for the next 15 weeks" do
    params = { weekly_interval: 2, weeks_count: 15, weekly_weekdays: [ :wednesday, :saturday ] }
    tm = Time.now.in_time_zone("Moscow")
    @em.from_params(params: params, tz: tm)
    assert @em.save, true
    assert @em.rule.between(tm, tm + 15.weeks).count == 15, true
  end

  test "event should recur every 3 months on the 2nd Tuesday of the month when between the 7th and 20th for the next 12 months" do
    params = { monthly_interval: 3, months_count: 12, monthly_days: [ 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ], monthly_dow: 2, monthly_weekdays: [ :tuesday ] }
    tm = Time.new(2024, 7, 17, 18, 44, 0).in_time_zone("Moscow")
    @em.from_params(params: params, tz: tm)
    assert @em.save, true
    assert @em.rule.between(tm, tm + 12.months).count == 4, true
  end

  test "event should recur every other year on 1st Monday in February for the next 3 years, starting in 2024" do
    params = { yearly_interval: 2, years_count: 3, first_year: 2024, yearly_months: [ 1 ], yearly_dow: [ 1 ], yearly_weekdays: [ :monday ] }
    tm = Time.new(2024, 7, 17, 18, 44, 0).in_time_zone("Moscow")
    @em.from_params(params: params, tz: tm)
    assert @em.save, true
    assert @em.rule.between(tm, tm + 4.years).count == 2, true
  end
end
