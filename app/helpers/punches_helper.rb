module PunchesHelper
  def tell_state(record)
    record.comment.blank? ?
      I18n.t("#{record.class.to_s.underscore}.#{record.state}") :
      show_comment_and_state(record).html_safe
  end
  def show_comment_and_state(record)
    content_tag(:div, class: "flex", alt: record.comment) do
      code = [ I18n.t("#{record.class.to_s.underscore}.#{record.state}") ]
      code << content_tag(:svg, class: "ml-2 text-sky-600", xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor", stroke_width: "1.5", stroke: "currentColor") do
        content_tag(:path, nil, d: "M240-400h320v-80H240v80Zm0-120h480v-80H240v80Zm0-120h480v-80H240v80ZM80-80v-720q0-33 23.5-56.5T160-880h640q33 0 56.5 23.5T880-800v480q0 33-23.5 56.5T800-240H240L80-80Zm126-240h594v-480H160v525l46-45Zm-46 0v-480 480Z")
      end
      code.join.html_safe
    end
  end
  def show_link_to_punch_clock(punch_clock)
    link_to(punch_clock.name, punch_clock_url(punch_clock))
  rescue
    ""
  end
  def show_link_to_punch_card(punch)
    lbl = punch.punched_at.strftime("%d/%m/%y %H:%M")
    link_to(lbl, punch_card_url(punch.punch_card))
  rescue
    lbl
  end
end
