module UsersHelper
  def global_queries?(usr)
    return false if usr.blank?
    usr.global_queries?
  end
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
end
