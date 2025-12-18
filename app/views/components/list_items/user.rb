class ListItems::User < ListItems::ListItem
  # tenant_id
  # email
  # encrypted_password
  # reset_password_token
  # reset_password_sent_at
  # remember_created_at
  # sign_in_count
  # current_sign_in_at
  # last_sign_in_at
  # current_sign_in_ip
  # last_sign_in_ip
  # confirmation_token
  # confirmed_at
  # confirmation_sent_at
  # role
  # locale
  # time_zone
  # created_at
  # updated_at
  # invitation_token
  # invitation_created_at
  # invitation_sent_at
  # invitation_accepted_at
  # invitation_limit
  # invited_by_type
  # invited_by_id
  # invitations_count
  # name
  # global_queries
  # locked_at
  # failed_attempts
  # unlock_token
  # team_id
  # state
  # eu_state
  # color
  # pincode
  # pos_token
  # job_title
  # hired_at
  # birthday
  # last_punched_at
  # cell_phone
  # blocked_from_punching
  # encrypted_otp_secret
  # encrypted_otp_secret_iv
  # encrypted_otp_secret_salt
  # consumed_timestep
  # otp_required_for_login

  def show_recipient_link
    lbl = resource.name.blank? ? resource.email : resource.name
    p(class: "text-sm/6 font-semibold text-gray-900 dark:text-white") do
      link_to user_url(resource), data: { turbo_action: "advance", turbo_frame: "form", tabindex: "-1" }, class: "hover:underline" do
        plain lbl
      end
    end
  end

  def show_matter_link
    div(class: "flex flex-row items-center") do
      show_matter_mugshot
      if user&.global_queries? && resource.respond_to?(:tenant)
        span(class: "hidden md:inline text-xs mr-2") { show_resource_link(resource: resource.tenant) }
      end unless resource_class == Tenant
      lbl = resource.name.blank? ? "" : resource.email
      span(class: "md:inline text-xs truncate") do
        link_to(resource_url,
          class: "truncate hover:underline inline grow flex-nowrap",
          data: { turbo_action: "advance", turbo_frame: "form" },
          tabindex: -1) do
          span(class: "hidden sm:inline mr-2") { resource&.team&.name }
          plain lbl
        end
      end
    end
  end

  def show_left_mugshot
    div(class: "flex items-center") do
      input(type: "checkbox", name: "batch[ids][]", value: resource.id, class: "hidden batch mort-form-checkbox mr-2")
      mugshot(resource, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
    end
  end

  def show_matter_mugshot
    mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    p(class: "text-sm font-medium text-gray-900 dark:text-white") do
      span(class: "truncate mr-2") { resource.sign_in_count }
      span(class: "hidden sm:inline truncate") { l(resource.last_sign_in_at, format: :short) }
    end
  end

  def show_time_info
    span(class: "text-xs text-sky-300 mr-2") { WORK_STATE_H[resource.state] }
    span(class: "truncate") do
      plain l(resource.created_at, format: :date)
    end
  end
end
