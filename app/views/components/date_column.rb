class DateColumn < Column
  def th_value(&block)
    th(class: @class) do
      plain format_date(value)
      yield if block_given?
    end
  end

  def td_value(&block)
    td(class: @class) do
      plain format_date(value)
      yield if block_given?
    end
  end

  def div_value(&block)
    value.blank? ?
      div { "&nbsp;".html_safe } :
      div(class: @class) do
        if block_given?
          yield format_date(value)
        else
          @sort ? build_link(value) : plain(format_date(value))
        end
      end
  end

  def format_date(date)
    date.strftime("%d/%m/%Y")
  end
end
