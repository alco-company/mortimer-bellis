module MortimerHelper
  def mortimer_version
    content_tag :h3, class: "text-xs text-slate-200" do
      [ m_label, m_version ].join.html_safe
    end
  end

  def m_label
    tag.span "Mortimer version: "
  end

  def m_version
    tag.span ENV["MORTIMER_VERSION"], class: "text-xs text-slate-200 font-thin"
  end
end
