module MortimerHelper
  def mortimer_version
    content_tag :h3, class: "text-xs text-slate-200" do
      safe_join([ user_id, m_label, m_version ])
    end.html_safe
  end

  def m_label
    tag.span "Mortimer version: "
  end

  def m_version
    tag.span ENV["MORTIMER_VERSION"], class: "text-xs text-slate-200 font-thin"
  end

  def user_id
    tag.span "#{Current.user&.id} ", class: "text-xs text-sky-200 font-bold"
  end
end
