module PunchCardsHelper
  def show_work_minutes(punch_card)
    show_error_badge(new_punch_card_url, I18n.t("punch_cards.list.punch_card_does_not_exist")) if punch_card.nil?
    (punch_card.work_minutes.nil? || punch_card.work_minutes < 0) ?
      show_warning_badge(punch_card_url(punch_card), I18n.t("punch_cards.list.err_calculating_work_minutes")) :
      display_hours_minutes(punch_card.work_minutes)
  end

  def show_warning_badge(url, message)
    content_tag(:a, class: "btn btn-warning", href: url) do
      content_tag(:span, class: "inline-flex items-center rounded-full bg-pink-50 px-2 py-1 text-xs font-medium text-pink-700 ring-1 ring-inset ring-pink-700/10") do
        message
      end
    end
  end
end
