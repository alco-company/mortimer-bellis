class Users::Form < ApplicationForm
  def view_template(&)
    view_only field("tenant.name").input()
    if model.superadmin? and not user.superadmin?
      view_only field(:name).input()
      view_only field(:email).input()
      view_only field(:mugshot).file(class: "mort-form-text")
      view_only field(:locale).input()
      view_only field(:time_zone).input()
    else
      row field(:name).input()
      row field(:email).input()
      row field(:pincode).input()
      row field(:hourly_rate).input(help: "https://mortimer.pro/help/hour_rate")
      row field(:team_id).select(Team.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_team"), class: "mort-form-select")
      row field(:mugshot).file(class: "mort-form-file")
      row field(:locale).select(User.locales, prompt: I18n.t(".select_user_locale"), class: "mort-form-select")
      row field(:time_zone).select(User.time_zones_for_phlex, class: "mort-form-select")
    end
    role_select
    if user.superadmin?
      # row field(:remember_created_at).datetime(class: "mort-form-datetime")
      row field(:current_sign_in_ip).input()
      view_only field(:confirmation_token).input()
      view_only field(:confirmation_sent_at).datetime(class: "mort-form-datetime")
      row field(:confirmed_at).datetime(class: "mort-form-datetime")
      row field(:invitation_limit).input()
    end
    view_only field(:reset_password_sent_at).datetime(class: "mort-form-datetime")
    view_only field(:current_sign_in_at).datetime(class: "mort-form-datetime")
    view_only field(:invitations_count).input()
    # view_only field(:encrypted_password).input()
    # view_only field(:reset_password_token).input()
    view_only field(:sign_in_count).input()
    view_only field(:last_sign_in_at).datetime(class: "mort-form-datetime")
    view_only field(:last_sign_in_ip).input()
    view_only field(:invitation_token).input()
    view_only field(:invitation_created_at).datetime(class: "mort-form-datetime")
    view_only field(:invitation_sent_at).datetime(class: "mort-form-datetime")
    view_only field(:invitation_accepted_at).datetime(class: "mort-form-datetime")
    # view_only field(:global_queries).boolean(class: "mort-form-text")
    view_only field("invited_by.name").input(value: (model.invited_by.send :email)) if model.invited_by
  end

  def role_select
    if user.id == model.id or user.user?
      return view_only field(:role).enum_select(User.roles.keys, class: "mort-form-select")
    end
    if user.superadmin?
      row field(:role).enum_select(User.roles.keys, class: "mort-form-select")
    else
      return view_only field(:role).enum_select(User.roles.keys, class: "mort-form-select") if model.superadmin?
      row field(:role).enum_select(User.roles.keys - [ "superadmin" ], class: "mort-form-select")
    end
  end
end
