class ListItems::InvoiceItem < ListItems::ListItem
  # tenant_id
  # invoice_id
  # project_id
  # product_id
  # product_guid
  # description
  # comments
  # quantity
  # account_number
  # unit
  # discount
  # line_type
  # base_amount_value
  # base_amount_value_incl_vat
  # total_amount
  # total_amount_incl_vat

  def show_left_mugshot
    # mugshot(resource, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain "%s %s" % [ resource.product.name, resource.quantity ]
  end
end
