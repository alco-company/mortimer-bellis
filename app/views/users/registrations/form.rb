class Users::Registrations::Form < ApplicationForm
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::T

  def view_template(&)
    div(class: "mx-auto w-72 sm:w-96 mt-4") do
      h1 { I18n.t("users.edit_profile.name") }
      plain helpers.mortimer_version

      if Current.user.superadmin?
        row field(:tenant_id).select(Tenant.all.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_tenant"), class: "mort-form-select")
        row field(:global_queries).boolean(class: "mort-form-bool")
      else
        view_only field("tenant.name").input()
      end
      row field(:name).input()
      row field(:email).input()
      row field(:pincode).input()
      # row field(:team_id).select(Team.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_team"), class: "mort-form-select")
      row field(:mugshot).file(class: "mort-form-file")
      row field(:locale).select(User.locales, prompt: I18n.t(".select_user_locale"), class: "mort-form-select")
      row field(:time_zone).select(User.time_zones_for_phlex, class: "mort-form-select")
      div(class: "mort-field") do
        render NotificationOutlet.new
      end
      div(class: "mort-field") do
        render TwoFactorField.new
      end
      # set_password
      buy_product
      delete_account
    end
  end

  def set_password
    div(class: "p-4 rounded-md shadow-xs bg-sky-100") do
      i(class: "text-xs") do
        plain I18n.t("users.registrations.edit.sign_up.leave_empty")
      end
      div(class: "mort-field") do
        # if @minimum_password_length
        #   whitespace
        #   em { I18n.t(".sign_up.minimum", count: @minimum_password_length) }
        #   whitespace
        # end
        row field(:password).password(
          focus: false,
          autocomplete: true,
          placeholder: I18n.t("users.enter_password"),
          maxlength: 72,
          "data-password-strength-target": :password,
          "data-action":
            "input->password-strength#updateStrength",
          class: "mort-form-text")
        div(
          data_password_strength_target: "strengthIndicator",
          class: "mt-0 pl-3 text-xs"
        )
      end
      div(class: "mort-field") do
        row field(:password_confirmation).password(
          autocomplete: true,
          focus: false,
          placeholder: I18n.t("users.reenter_password"),
          class: "mort-form-text")
      end
      div(class: "mort-field") do
        row field(:current_password).password(
          placeholder: I18n.t("users.enter_current_password"),
          autocomplete: true,
          focus: false,
          class: "mort-form-text"
        )
        i(class: "text-xs") do
          I18n.t("users.registrations.edit.sign_up.need_current_password")
        end
      end
    end
  end
end
