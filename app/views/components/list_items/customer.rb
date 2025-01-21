class ListItems::Customer < ListItems::ListItem
  # tenant_id
  # erp_guid
  # name
  # street
  # zipcode
  # city
  # phone
  # email
  # vat_number
  # ean_number
  # created_at
  # updated_at
  # external_reference
  # is_person
  # is_member
  # is_debitor
  # is_creditor
  # country_key
  # webpage
  # att_person
  # payment_condition_type
  # payment_condition_number_of_days
  # member_number
  # company_status
  # vat_region_key
  # invoice_mail_out_option_key

  def show_left_mugshot
    # mugshot(resource, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain "%s %s" % [ resource.name, resource.street ]
  end
end
