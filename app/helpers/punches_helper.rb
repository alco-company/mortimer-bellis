module PunchesHelper
  def show_link_to_punch_clock punch_clock
    link_to(punch_clock.name, punch_clock_url(punch_clock))
  rescue
    ""
  end
end
