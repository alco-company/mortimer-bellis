module ApplicationHelper
  include Pagy::Frontend

  def say(msg)
    Rails.logger.info "==============================="
    Rails.logger.info msg
    Rails.logger.info "==============================="
  end

  def menu_items
    items = []
    if user_signed_in?
      if current_user.superadmin?
        items += [
          { title: I18n.t("menu.accounts"), url: accounts_url },
          { title: I18n.t("menu.holidays"), url: holidays_url },
          { title: I18n.t("menu.pages"), url: pages_url },
          { title: I18n.t("menu.users"), url: users_url }
        ]
      end
      if current_user.admin?
        items += [
          { title: I18n.t("menu.account"), url: account_url(Current.account) },
          { title: I18n.t("menu.users"), url: users_url }
        ]
      end
      items + [
        { title: I18n.t("menu.teams"), url: teams_url },
        { title: I18n.t("menu.locations"), url: locations_url },
        { title: I18n.t("menu.punch_clocks"), url: punch_clocks_url },
        { title: I18n.t("menu.employees"), url: employees_url },
        { title: I18n.t("menu.punch_cards"), url: punch_cards_url },
        { title: I18n.t("menu.punches"), url: punches_url }
        # { title: I18n.t("menu.motds"), url: motds_url },
      ]
    else
      items << { title: I18n.t("menu.login"), url: new_user_session_url }
    end
  end
end
