class BooleanColumn < Column
  def th_value(&block)
    th(class: @class) do
      plain true_false(value)
      yield if block_given?
    end
  end

  def td_value(&block)
    td(class: @class) do
      plain true_false(value)
      yield if block_given?
    end
  end

  def div_value(&block)
    value.blank? ?
      div { "&nbsp;".html_safe } :
      div(class: @class) do
        if block_given?
          yield value
        else
          @sort ? build_link(true_false(value)) : plain(true_false(value))
        end
      end
  end

  def true_false(value)
    value ? I18n.t("yes") : I18n.t("no")
  end
end
