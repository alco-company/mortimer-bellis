module ApplicationHelper
  include Pagy::Frontend

  #
  # helper for web_push
  def web_push_public_key_meta_tag(web_push_public_key: ENV.fetch("VAPID_PUBLIC_KEY"))
    tag.meta name: "web_push_public", content: Base64.urlsafe_decode64(web_push_public_key).bytes.to_json
  end

  def show_add_new_button
    case params.dig(:controller)
    when "settings"
    when "calls"; link_to("New Call", new_call_path, data: { turbo_stream: true }, class: "mort-btn-primary", role: "menuitem", tabindex: "-1", id: "user-menu-item-0")
    when "users"; link_to(t("profile.invite_new_user"), users_invitations_new_url, data: { turbo_stream: false }, class: "mort-btn-primary mr-2", role: "menuitem", tabindex: "-1", id: "user-menu-item-0") unless Current.user.user?
    else
      links = []
      links.push (
        button_to(time_materials_url, params: { "play" => "start" }) do
          content_tag(:span, "Add new", class: "sr-only") +
          content_tag(:span, class: "inline-flex items-center rounded-md bg-white px-1.5 py-2 text-xs font-medium text-gray-600 sm:ring-1 ring-inset ring-gray-500/10") do
            render(Icons::Play.new css: "h-6 w-6 text-gray-400") +
            content_tag(:span, t("#{ resource_class.table_name }.list.play"), class: "hidden pl-2 sm:inline text-gray-400 text-2xs")
          end
        end
      ).html_safe if params.dig(:controller) == "time_materials"
      # links.push (link_to(new_resource_url, id: "new_list_item", class: "-my-2 flex items-center rounded-md p-2 text-gray-400 hover:text-gray-600 focus:outline-hidden focus:ring-1 focus:ring-sky-200", data: { turbo_frame: "form" }) do
      #   content_tag(:span, "Add new", class: "sr-only") +
      #   content_tag(:span, class: "inline-flex items-center rounded-md bg-white px-1.5 py-2 text-xs font-medium text-gray-600 sm:ring-1 ring-inset ring-gray-500/10") do
      #     render(Icons::Play.new css: "h-6 w-6 text-gray-400") +
      #     content_tag(:span, t("#{ resource_class.table_name }.list.new"), class: "hidden pl-2 sm:inline text-gray-400 text-2xs")
      #   end
      # end).html_safe if params.dig(:controller) == "time_materials"
      links.push (link_to(new_resource_url, id: "new_list_item", class: "-my-2 flex items-center rounded-md p-2 text-gray-400 hover:text-gray-600 focus:outline-hidden focus:ring-1 focus:ring-sky-200", data: { turbo_frame: "form" }) do
        content_tag(:span, "Add new", class: "sr-only") +
        content_tag(:span, class: "inline-flex items-center rounded-md bg-white px-1.5 py-2 text-xs font-medium text-gray-600 sm:ring-1 ring-inset ring-gray-500/10") do
          render(Icons::Add.new css: "h-6 w-6 text-gray-400") +
          content_tag(:span, t("#{ resource_class.table_name}.list.new"), class: "hidden pl-2 sm:inline text-gray-400 text-2xs")
        end
      end).html_safe
      links.join.html_safe
    end if user_can_create? && !(resource_class == Filter)
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
