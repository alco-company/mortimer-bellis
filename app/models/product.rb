class Product < ApplicationRecord
  include Tenantable

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_product_number, ->(product_number) { where("product_number LIKE ?", "%#{product_number}%") if product_number.present? }
  scope :by_quantity, ->(quantity) { where("quantity LIKE ?", "%#{quantity}%") if quantity.present? }
  scope :by_unit, ->(unit) { where("unit LIKE ?", "%#{unit}%") if unit.present? }
  scope :by_base_amount_value, ->(base_amount_value) { where("base_amount_value LIKE ?", "%#{base_amount_value}%") if base_amount_value.present? }
  scope :by_account_number, ->(account_number) { where("account_number LIKE ?", "%#{account_number}%") if account_number.present? }
  scope :by_external_reference, ->(external_reference) { where("external_reference LIKE ?", "%#{external_reference}%") if external_reference.present? }

  # validates :name, presence: true, uniqueness: { scope: :tenant_id, message: I18n.t("products.errors.messages.name_exist") }
  validates :base_amount_value, presence: true
  validates :quantity, presence: true
  validates :unit, presence: true # hours, parts, km, day, week, month, kilogram, cubicMetre, set, litre, box, case, carton, metre, package, shipment, squareMetre, session, tonne, unit, other
  validates :account_number, presence: true

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_name(flt["name"])
      .by_product_number(flt["product_number"])
      .by_quantity(flt["quantity"])
      .by_unit(flt["unit"])
      .by_base_amount_value(flt["base_amount_value"])
      .by_account_number(flt["account_number"])
      .by_external_reference(flt["external_reference"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Products::Form.new resource, editable: editable
  end

  def self.add_from_erp(item)
    return false unless item["Name"].present?
    product = Product.find_or_create_by(tenant: Current.tenant, erp_guid: item["ProductGuid"])
    product.name = item["Name"]
    product.product_number = item["ProductNumber"]
    product.quantity = item["Quantity"]
    product.unit = item["Unit"]
    product.base_amount_value = item["BaseAmountValue"]
    product.account_number = item["AccountNumber"]
    product.base_amount_value_incl_vat = item["BaseAmountInclVat"]
    product.total_amount = item["TotalAmount"]
    product.total_amount_incl_vat = item["TotalAmountInclVat"]
    product.external_reference = item["ExternalReference"]
    product.save
  end
end
