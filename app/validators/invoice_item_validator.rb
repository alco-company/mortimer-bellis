#
# check for customer, time, about, product, product_name, comment, rate, quantity, unit_price, discount
# if quantity is set, then product_name cannot be blank
# if product is set, then quantity cannot be blank
# if time is set, then quantity and product_name must be blank
# if rate is set, then time cannot be blank and product/product_name and quantity must be blank
# if discount is set, then product/product_name and quantity cannot be blank
# if discount is set, then discount must be in the format of 0[,.]00 or 0[,.]00%
# if unit_price is set, then unit_price must be in the format of 0[,.]00
# if quantity is set, then quantity must be in the format of 0[,.]00
# if rate is set, then rate must be in the format of 0[,.]00
# if time is set, then time must be in the format of 0[,.]00
# if kilometers is set, then kilometers must be in the format of 0000
# if time, quantity, and kilometers are all blank, then comment cannot be blank
# if time is set, then kilometers and quantity must be blank
# if quantity is set, then time and kilometers must be blank
# if kilometers is set, then time and quantity must be blank
# if product is set, then product must exist
# if customer is set, then customer must exist
# if project_name is set, then project must exist - create it if it doesn't
class InvoiceItemValidator
  include ActiveModel::Model

  attr_accessor :quantity, :product_name, :product, :time, :rate, :discount, :unit_price,
                :kilometers, :comment, :customer, :customer_name, :project_name, :project, :is_invoice

  validates :product_name, presence: true, if: -> { quantity.present? }
  validates :quantity, presence: true, if: -> { product.present? }
  validate :time_requires_blank_fields
  validate :rate_requires_conditions
  validate :discount_requires_conditions
  validate :unit_price_format
  validate :quantity_format
  validate :rate_format
  validate :time_format
  validate :kilometers_format
  validate :comment_required_if_no_fields
  validate :mutual_exclusivity_of_time_quantity_and_kilometers
  validate :product_must_exist
  validate :customer_must_exist
  validate :project_name_creates_project_if_not_found

  def initialize(tm)
    @quantity = tm.quantity
    @product_name = tm.product_name
    @product = tm.product
    @time = tm.time
    @rate = tm.rate
    @discount = tm.discount
    @unit_price = tm.unit_price
    @kilometers = tm.kilometers
    @comment = tm.comment
    @customer = tm.customer
    @customer_name = tm.customer_name
    @project_name = tm.project_name
    @project = tm.project
    @is_invoice = tm.is_invoice
  end

  private

  # Custom validation methods
  def time_requires_blank_fields
    if time.present? && (quantity.present? || product_name.present?)
      errors.add(:time, tr("quantity_product_name_must_blank"))
    end
  end

  def rate_requires_conditions
    if rate.present?
      errors.add(:rate, tr("time_must_be_set")) if time.blank?
      errors.add(:rate, tr("product_name_product_quantity_must_blank")) if product.present? || product_name.present? || quantity.present?
    end
  end

  def discount_requires_conditions
    if discount.present?
      errors.add(:discount, tr("product_name_quantity_must_be_set")) if product_name.blank? || quantity.blank?
      unless discount =~ /\A\d*[,.]?\d{2}%?\z/
        errors.add(:discount, tr("format_wrong_number")) #  0[,.]00 or 0[,.]00%
      end
    end
  end

  def unit_price_format
    if unit_price.present? && unit_price !~ /\A\d*[,.]?\d{0,3}\z/
      errors.add(:unit_price, tr("format_wrong_number")) #  0[,.]00 or 0[,.]00%
    end
  end

  def quantity_format
    if quantity.present? && quantity !~ /\A\d*[,.]?\d{0,3}\z/
      errors.add(:quantity, tr("format_wrong_number")) #  0[,.]00 or 0[,.]00%
    end
  end

  def rate_format
    if rate.present? && rate !~ /\A\d*[,.]?\d{0,2}\z/
      errors.add(:rate, tr("format_wrong_number")) #  0[,.]00 or 0[,.]00%
    end
  end

  def time_format
    if time.present? && time !~ /\A\d*[,:.]?\d{0,2}\z/
      errors.add(:time, tr("format_wrong_number_time")) #  0[,.]00 or 0[,.]00%
    end
  end

  def kilometers_format
    if kilometers.present? && kilometers !~ /\A\d{1,8}\z/
      errors.add(:kilometers, tr("format_wrong_number_digits")) # 0000..0
    end
  end

  def comment_required_if_no_fields
    if time.blank? && quantity.blank? && kilometers.blank? && comment.blank?
      errors.add(:comment, tr("cannot_be_blank_when_time_quantity_km_blank"))
    end
  end

  def mutual_exclusivity_of_time_quantity_and_kilometers
    if time.present? && (kilometers.present? || quantity.present?)
      errors.add(:time, tr("km_quantity_must_blank"))
    elsif quantity.present? && (time.present? || kilometers.present?)
      errors.add(:quantity, tr("time_km_must_blank"))
    elsif kilometers.present? && (time.present? || quantity.present?)
      errors.add(:kilometers, "time_quantity_must_blank")
    end
  end

  def product_must_exist
    if product.present? && !Product.by_tenant.find(product.id)
      errors.add(:product, tr("must_exist"))
    end
  end

  def customer_must_exist
    if is_invoice
      if (customer.present? || customer_name.present?) && !Customer.by_tenant.find(customer.id)
        errors.add(:customer, tr("not_found_search_customer_again"))
      elsif customer.present? || customer_name.present?
      else
        errors.add(:customer, tr("must_exist"))
      end
    end
  end

  def project_name_creates_project_if_not_found
    if project_name.present?
      self.project = Project.by_tenant.find_or_create_by(tenant: Current.tenant, customer: customer, name: project_name)
    end
  end

  def tr(msg)
    I18n.t("invoice_item.issues.#{msg}")
  end
end
