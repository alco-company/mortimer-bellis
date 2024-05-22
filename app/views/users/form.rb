class Users::Form < ApplicationForm
  def view_template(&)
    view_only field("account.name").input(class: "mort-form-text")
    if model.superadmin? and not Current.user.superadmin?
      view_only field(:name).input(class: "mort-form-text")
      view_only field(:email).input(class: "mort-form-text")
      view_only field(:mugshot).file(class: "mort-form-text")
      view_only field(:locale).input(class: "mort-form-text")
      view_only field(:time_zone).input(class: "mort-form-text")
    else
      row field(:name).input(class: "mort-form-text")
      row field(:email).input(class: "mort-form-text")
      row field(:mugshot).file(class: "mort-form-text")
      row field(:locale).input(class: "mort-form-text")
      row field(:time_zone).input(class: "mort-form-text")
    end
    role_select
    if Current.user.superadmin?
      row field(:remember_created_at).datetime(class: "mort-form-text")
      row field(:current_sign_in_ip).input(class: "mort-form-text")
      row field(:confirmation_token).input(class: "mort-form-text")
      row field(:confirmation_sent_at).datetime(class: "mort-form-text")
      row field(:confirmed_at).datetime(class: "mort-form-text")
      row field(:invitation_limit).input(class: "mort-form-text")
    end
    view_only field(:reset_password_sent_at).datetime(class: "mort-form-text")
    view_only field(:current_sign_in_at).datetime(class: "mort-form-text")
    view_only field(:invitations_count).input(class: "mort-form-text")
    view_only field(:encrypted_password).input(class: "mort-form-text")
    view_only field(:reset_password_token).input(class: "mort-form-text")
    view_only field(:sign_in_count).input(class: "mort-form-text")
    view_only field(:last_sign_in_at).datetime(class: "mort-form-text")
    view_only field(:last_sign_in_ip).input(class: "mort-form-text")
    view_only field(:invitation_token).input(class: "mort-form-text")
    view_only field(:invitation_created_at).datetime(class: "mort-form-text")
    view_only field(:invitation_sent_at).datetime(class: "mort-form-text")
    view_only field(:invitation_accepted_at).datetime(class: "mort-form-text")
    # view_only field(:global_queries).boolean(class: "mort-form-text")
    view_only field("invited_by.name").input(class: "mort-form-text", value: (model.invited_by.send :email)) if model.invited_by
  end

  def role_select
    if Current.user.id == model.id or Current.user.user?
      return view_only field(:role).enum_select(User.roles.keys, class: "mort-form-text")
    end
    if Current.user.superadmin?
      row field(:role).enum_select(User.roles.keys, class: "mort-form-text")
    else
      return view_only field(:role).enum_select(User.roles.keys, class: "mort-form-text") if model.superadmin?
      row field(:role).enum_select(User.roles.keys - [ "superadmin" ], class: "mort-form-text")
    end
  end
end
