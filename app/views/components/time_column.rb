class TimeColumn < DateColumn
  def format_datetime(datetime)
    datetime.strftime("%H:%M")
  end
end
