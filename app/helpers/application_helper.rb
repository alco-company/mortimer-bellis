module ApplicationHelper
  include Pagy::Frontend

  #
  # helper for web_push
  def web_push_public_key_meta_tag(web_push_public_key: ENV.fetch("VAPID_PUBLIC_KEY"))
    tag.meta name: "web_push_public", content: Base64.urlsafe_decode64(web_push_public_key).bytes.to_json
  end

  # def prev_page_link(url, page)
  #   if url =~ /page=/
  #     url.sub(/page=\d+/, "page=#{page || 1}")
  #   else
  #     url + "?page=#{page || 1}"
  #   end
  # end

  # def next_page_link(url, page)
  #   if url =~ /page=/
  #     url.sub(/page=\d+/, "page=#{page || 1}")
  #   else
  #     url + "?page=#{page || 1}"
  #   end
  # end

  def say(msg)
    Rails.logger.info { "===============================" }
    Rails.logger.info { msg }
    Rails.logger.info { "===============================" }
  end
end
