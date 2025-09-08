module ViewComponentsHelper
  def punch_button(user:, punch_clock:)
    render PunchButtonComponent.new user: user, punch_clock: punch_clock
  end

  def time_material_button(user:, play: true)
    render TimeMaterialButtonComponent.new user: user, play: play
  end

  def time_material_form(**attribs, &block)
    render TimeMaterialForm.new(**attribs), &block
  end

  def render_component(component, locals = {})
    render partial: component, locals: locals
  end

  def render_today_header(**attribs, &block)
    render TodayHeader.new(**attribs), &block
  end

  def render_punch_card_payroll(**attribs, &block)
    render PunchCardPayroll.new(**attribs), &block
  end

  def render_mortimer_footer(**attribs, &block)
    render MortimerFooter.new(**attribs), &block
  end

  def render_punch_clock_header(**attribs, &block)
    render PunchClockHeader.new(**attribs), &block
  end

  def render_logo(**attribs, &block)
    render LogoComponent.new(**attribs), &block
  end

  def render_scan_icon
    render ScanIconComponent.new
  end

  # def render_menu(**attribs, &block)
  #   render MenuComponent.new(**attribs), &block
  # end

  def render_mobile_sidebar(**attribs, &block)
    render MobileSidebarComponent.new(**attribs), &block
  end

  def render_topbar(**attribs, &block)
    render TopbarComponent.new(**attribs), &block
  end

  def render_view_notifications(**attribs, &block)
    render ViewNotificationsComponent.new(**attribs), &block
  end

  def render_vertical_menu(**attribs, &block)
    render VerticalMenuComponent.new(**attribs), &block
  end

  def render_contextmenu **attribs, &block
    attribs[:user] ||= Current.get_user
    render Contextmenu.new(**attribs), &block
  end

  def render_boolean_column **attribs, &block
    render BooleanColumn.new(**attribs), &block
  end

  def render_text_column **attribs, &block
    render TextColumn.new(**attribs), &block
  end

  def render_number_column **attribs, &block
    render NumberColumn.new(**attribs), &block
  end

  def render_date_column **attribs, &block
    render DateColumn.new(**attribs), &block
  end
  def render_datetime_column **attribs, &block
    render DateTimeColumn.new(**attribs), &block
  end
  def render_time_column **attribs, &block
    render TimeColumn.new(**attribs), &block
  end
end
