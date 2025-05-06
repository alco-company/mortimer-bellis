module DashboardsHelper
  def billed_hours
    @time_materials = Current.get_user.time_materials.billed
    "%s t. %s min." % billed_minutes.to_i.divmod(60)
  end

  def billed_hours_delta
    last_minutes = case @range_view
    when "today"; calc_minutes Time.current.to_date - 1.day, true
    when "week"; calc_minutes Time.current.to_date - 1.week, true
    when "month"; calc_minutes Time.current.to_date - 1.month, true
    when "year"; calc_minutes Time.current.to_date - 1.year, true
    end
    return 0 if last_minutes == 0
    (billed_minutes - last_minutes) / last_minutes * 100
  end

  def drafted_hours
    @time_materials = Current.get_user.time_materials.drafted
    "%s t. %s min." % drafted_minutes.to_i.divmod(60)
  end

  def drafted_minutes
    @drafted_minutes ||= calc_minutes Time.current.to_date
  end

  def billed_minutes
    @billed_minutes ||= calc_minutes Time.current.to_date
  end

  def calc_minutes(now, last = false)
    if last
      mins = case @range_view
      when "today"; @time_materials.where("wdate = ?", now).sum(:registered_minutes)
      when "week"; @time_materials.where("wdate >= ? and wdate <=?", now.beginning_of_week, now).sum(:registered_minutes)
      when "month"; @time_materials.where("wdate >= ? and wdate <=?", now.beginning_of_month, now).sum(:registered_minutes)
      when "year"; @time_materials.where("wdate >= ? and wdate <=?", now.beginning_of_year, now).sum(:registered_minutes)
      end
    else
      mins = case @range_view
      when "today"; @time_materials.where("wdate = ?", now).sum(:registered_minutes)
      when "week"; @time_materials.where("wdate >= ?", now.beginning_of_week).sum(:registered_minutes)
      when "month"; @time_materials.where("wdate >= ?", now.beginning_of_month).sum(:registered_minutes)
      when "year"; @time_materials.where("wdate >= ?", now.beginning_of_year).sum(:registered_minutes)
      end
    end
    mins = mins.to_i
  end
end
