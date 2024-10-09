class InvoiceItem < ApplicationRecord
  include Tenantable
  belongs_to :invoice
  belongs_to :product
  belongs_to :project, optional: true

  scope :by_invoice_number, ->(invoice_number) { joins(:invoice).where("invoices.invoice_number LIKE ?", "%#{invoice_number}%") if invoice_number.present? }
  scope :by_product_name, ->(product_name) { joins(:product).where("products.name LIKE ? OR products.product_number LIKE ?", "%#{product_name}%", "%#{product_name}%") if product_name.present? }
  scope :by_description, ->(description) { where("description LIKE ?", "%#{description}%") if description.present? }
  scope :by_unit, ->(unit) { where("unit LIKE ?", "%#{unit}%") if unit.present? }
  scope :by_line_type, ->(line_type) { where("line_type LIKE ?", "%#{line_type}%") if line_type.present? }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_invoice_number(flt["invoice_number"])
      .by_product_name(flt["product_name"])
      .by_description(flt["description"])
      .by_unit(flt["unit"])
      .by_line_type(flt["line_type"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    InvoiceItems::Form.new resource, editable: editable
  end

  def name
    description || product.name
  end

  #
  # Note: Dinero has no sense of projects
  #
  def self.add_from_erp(item, invoice)
    product = Product.find_by erp_guid: item["ProductGuid"]
    InvoiceItem.create(
      tenant: Current.tenant,
      invoice: invoice,
      product: product,
      description: item["Description"],
      comments: item["Comments"],
      quantity: item["Quantity"],
      # account_number: item["AccountNumber"],
      unit: item["Unit"],
      discount: item["Discount"],
      line_type: item["LineType"],
      base_amount_value: item["BaseAmountValue"]
    )
  end
end
