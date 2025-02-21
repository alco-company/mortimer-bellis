class ListItems::Invoice < ListItems::ListItem
  # tenant_id
  # customer_id
  # project_id
  # invoice_number
  # currency
  # state
  # mail_out_state
  # latest_mail_out_type
  # locale
  # external_reference
  # description
  # comment
  # invoice_date
  # payment_date
  # address
  # erp_guid
  # show_lines_incl_vat
  # invoice_template_id
  # contact_guid
  # payment_condition_number_of_days
  # payment_condition_type
  # reminder_fee
  # reminder_interest_rate
  # total_excl_vat_in_dkk
  # total_excl_vat
  # total_incl_vat_in_dkk
  # total_incl_vat
  # is_mobile_pay_invoice_enabled
  # is_penso_pay_enabled

  def show_left_mugshot
    div(class: "flex items-center") do
      input(type: "checkbox", name: "batch[ids][]", value: resource.id, class: "hidden batch mort-form-checkbox mr-2")
      # mugshot(resource.user, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
    end
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain "%s %s" % [ resource.customer.name, resource.invoice_date ]
  end
end
