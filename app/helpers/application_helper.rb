module ApplicationHelper
  include Pagy::Frontend


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

  def menu_items
    items = []
    if user_signed_in?
      if current_user.superadmin?
        items += [
          { title: I18n.t("menu.tenants"), url: tenants_url },
          { title: I18n.t("menu.holidays"), url: holidays_url },
          { title: I18n.t("menu.pages"), url: pages_url },
          { title: I18n.t("menu.users"), url: users_url }
        ]
      end
      if current_user.admin?
        items += [
          { title: I18n.t("menu.tenant"), url: tenant_url(Current.tenant) },
          { title: I18n.t("menu.users"), url: users_url }
        ]
      end
      items + [
        { title: I18n.t("menu.teams"), url: teams_url },
        { title: I18n.t("menu.locations"), url: locations_url },
        { title: I18n.t("menu.punch_clocks"), url: punch_clocks_url },
        { title: I18n.t("menu.users"), url: employees_url },
        { title: I18n.t("menu.punch_cards"), url: punch_cards_url },
        { title: I18n.t("menu.punches"), url: punches_url }
        # { title: I18n.t("menu.motds"), url: motds_url },
      ]
    else
      items << { title: I18n.t("menu.login"), url: new_user_session_url }
    end
  end
end
