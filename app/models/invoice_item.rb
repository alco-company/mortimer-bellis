class InvoiceItem < ApplicationRecord
  include Tenantable
  belongs_to :invoice
  belongs_to :product
  belongs_to :project, optional: true

  scope :by_fulltext, ->(query) { where("description LIKE :query OR unit LIKE :query OR line_type LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_invoice_number, ->(invoice_number) { joins(:invoice).where("invoices.invoice_number LIKE ?", "%#{invoice_number}%") if invoice_number.present? }
  scope :by_product_name, ->(product_name) { joins(:product).where("products.name LIKE ? OR products.product_number LIKE ?", "%#{product_name}%", "%#{product_name}%") if product_name.present? }
  scope :by_description, ->(description) { where("description LIKE ?", "%#{description}%") if description.present? }
  scope :by_unit, ->(unit) { where("unit LIKE ?", "%#{unit}%") if unit.present? }
  scope :by_line_type, ->(line_type) { where("line_type LIKE ?", "%#{line_type}%") if line_type.present? }

  def self.set_order(resources, field = :created_at, direction = :desc)
    resources.ordered(field, direction)
  end

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

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      "invoice_id",
      "project_id",
      "product_id",
      "product_guid"
      # "description"
      # "comments"
      # "quantity"
      # "account_number"
      # "unit"
      # "discount"
      # "line_type"
      # "base_amount_value"
      # "base_amount_value_incl_vat"
      # "total_amount"
      # "total_amount_incl_vat"
      # "created_at"
      # "updated_at"
    ]
    f = f - [
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  def self.associations
    [ [ Invoice, Product, Project ], [] ]
  end

  def self.form(resource:, editable: true)
    InvoiceItems::Form.new resource: resource, editable: editable
  end

  def name
    description || product.name
  end

  #
  # Note: Dinero has no sense of projects
  #
  def self.add_from_erp(item, invoice)
    product = Product.find_by erp_guid: item["ProductGuid"]
    if ii = InvoiceItem.create(
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
       Broadcasters::Resource.new(ii, { controller: "invoice_items" }).create
    end
  end
end
