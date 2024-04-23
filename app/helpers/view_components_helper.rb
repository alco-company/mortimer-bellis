module ViewComponentsHelper
	def render_component(component, locals = {})
		render partial: component, locals: locals
	end

	def render_today_header(**attribs, &block)
		render TodayHeader.new
	end

	def render_punch_card_payroll(**attribs, &block)
		render PunchCardPayroll.new **attribs, &block
	end

	def render_mortimer_footer(**attribs, &block)
		render MortimerFooter.new **attribs, &block
	end

	def render_punch_clock_header(**attribs, &block)
		render PunchClockHeader.new **attribs, &block
	end

	def render_logo
		render LogoComponent.new
	end

	def render_scan_icon 
		render ScanIconComponent.new
	end

	def render_contextmenu **attribs, &block
		render Contextmenu.new(**attribs), &block
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
end
