class ListItems::Product < ListItems::ListItem
  # tenant_id
  # erp_guid
  # name
  # product_number
  # quantity
  # unit
  # account_number
  # base_amount_value
  # base_amount_value_incl_vat
  # total_amount
  # total_amount_incl_vat
  # external_reference


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
    p(class: "text-sm font-medium text-gray-900 dark:text-white") do
      plain "%s %s" % [ resource.product_number, number_to_currency(resource.base_amount_value) ]
    end
  end
end
