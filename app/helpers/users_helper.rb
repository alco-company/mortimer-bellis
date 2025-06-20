module UsersHelper
  #
  def global_queries?(usr)
    return false if usr.blank?
    usr.global_queries?
  end

  def user_can_create?
    return true if Current.user.superadmin?
    return true if Current.user.admin? && params.dig(:controller) != "tenants"
    key = "allow_create_#{resource_class.to_s.underscore}"
    Current.user.can? key
  rescue
    false
  end

  #
  def user_mugshot(user, size: nil, css: "")
    size = size.blank? ? "40x40!" : size
    if (user.mugshot.attached? rescue false)
      image_tag(url_for(user.mugshot), class: css)
    else
      # size.gsub!("x", "/") if size =~ /x/
      # size.gsub!("!", "") if size =~ /!/
      image_tag "icons8-customer-64.png", class: css
    end
  rescue
    image_tag "icons8-customer-64.png", class: css
  end

  #
  def link_to_team_users_status(team)
    return unless User.by_tenant().count > 0
    first_user_token = "abc"
    link_to t("teams.list.user_status"), pos_users_url(t: team, api_key: first_user_token), class: "inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10", target: "_blank", data: { turbo_frame: "_top", turbo_stream: true }
  end

  def remaining_session_time
    last_request_at = warden.session(:user)["last_request_at"]
    timeout_in = 7.days
    return 0 unless last_request_at

    elapsed_time = Time.current.to_i - last_request_at.to_i
    remaining_time = timeout_in - elapsed_time
    [ remaining_time, 0 ].max # Ensure the value is not negative
  end
end
