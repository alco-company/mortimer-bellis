module ApplicationHelper
  include Pagy::Frontend


  #
  # helpers for List and ListItem
  #
  # show_resource_mugshot is placed in the left side of the ListItem
  def show_resource_mugshot(resource:, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
    case resource.class.name
    when "TimeMaterial"; user_mugshot(resource.user, css: css)
    end
  end
  #
  # show_secondary_info is placed in the upper right corner of the ListItem
  #
  def show_secondary_info(resource:)
    case resource.class.name
    when "User"
    when "TimeMaterial"; show_time_material_quantative resource: resource
    else; ""
    end
  end
  # end helpers for List and ListItem
  #



  def archive_resource_url(resource)
    case resource.class.name
    when "User"; archive_user_url(resource)
    when "TimeMaterial"; archive_time_material_url(resource)
    else; ""
    end
  end

  def prev_page_link(url, page)
    if url =~ /page=/
      url.sub(/page=\d+/, "page=#{page || 1}")
    else
      url + "?page=#{page || 1}"
    end
  end

  def next_page_link(url, page)
    if url =~ /page=/
      url.sub(/page=\d+/, "page=#{page || 1}")
    else
      url + "?page=#{page || 1}"
    end
  end

  def say(msg)
    Rails.logger.info { "===============================" }
    Rails.logger.info { msg }
    Rails.logger.info { "===============================" }
  end

  # def menu_items
  #   items = []
  #   if user_signed_in?
  #     if current_user.superadmin?
  #       items += [
  #         { title: I18n.t("menu.tenants"), url: tenants_url },
  #         { title: I18n.t("menu.holidays"), url: holidays_url },
  #         { title: I18n.t("menu.pages"), url: pages_url },
  #         { title: I18n.t("menu.users"), url: users_url }
  #       ]
  #     end
  #     if current_user.admin?
  #       items += [
  #         { title: I18n.t("menu.tenant"), url: tenant_url(Current.tenant) },
  #         { title: I18n.t("menu.users"), url: users_url }
  #       ]
  #     end
  #     items + [
  #       { title: I18n.t("menu.teams"), url: teams_url },
  #       { title: I18n.t("menu.locations"), url: locations_url },
  #       { title: I18n.t("menu.punch_clocks"), url: punch_clocks_url },
  #       { title: I18n.t("menu.users"), url: employees_url },
  #       { title: I18n.t("menu.punch_cards"), url: punch_cards_url },
  #       { title: I18n.t("menu.punches"), url: punches_url }
  #       # { title: I18n.t("menu.motds"), url: motds_url },
  #     ]
  #   else
  #     items << { title: I18n.t("menu.login"), url: new_user_session_url }
  #   end
  # end
end
