module PunchesHelper
  def tell_state(record)
    I18n.t("#{record.class.to_s.underscore}.#{record.state}")
  end
  def show_link_to_punch_clock(punch_clock)
    link_to(punch_clock.name, punch_clock_url(punch_clock))
  rescue
    ""
  end
end
