class Invoice < ApplicationRecord
  include Tenantable
  include Localeable

  belongs_to :customer
  belongs_to :project, optional: true
  has_many :invoice_items, dependent: :destroy

  scope :by_fulltext, ->(query) { where("invoice_number LIKE :query OR description LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_invoice_number, ->(invoice_number) { where("invoice_number LIKE ?", "%#{invoice_number}%") if invoice_number.present? }

  # validates :name, presence: true, uniqueness: { scope: :tenant_id, message: I18n.t("invoices.errors.messages.name_exist") }

  def self.set_order(resources, field = :created_at, direction = :desc)
    resources.ordered(field, direction)
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_invoice_number(flt["invoice_number"])
  rescue
    filter.destroy if filter
    all
  end

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      "customer_id",
      "project_id",
      # "invoice_number",
      # "currency",
      # "state",
      "mail_out_state",
      "latest_mail_out_type",
      # "locale",
      # "external_reference",
      # "description",
      # "comment",
      # "invoice_date",
      # "payment_date",
      # "address",
      "erp_guid",
      # "show_lines_incl_vat",
      "invoice_template_id",
      "contact_guid"
      # "payment_condition_number_of_days",
      # "payment_condition_type",
      # "reminder_fee",
      # "reminder_interest_rate",
      # "total_excl_vat_in_dkk",
      # "total_excl_vat",
      # "total_incl_vat_in_dkk",
      # "total_incl_vat",
      # "is_mobile_pay_invoice_enabled",
      # "is_penso_pay_enabled",
      # "created_at",
      # "updated_at"
    ]
    f = f - [
      "invoice_date",
      "payment_date",
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  def self.associations
    [ [ Customer, Project ], [ InvoiceItem ] ]
  end

  def self.form(resource:, editable: true)
    Invoices::Form.new resource: resource, editable: editable
  end

  def name
    invoice_number
  end

  def self.add_from_erp(item)
    return false unless item["Guid"].present?
    invoice = Invoice.find_or_create_by(tenant: Current.tenant, erp_guid: item["Guid"])
    invoice.invoice_number = item["Number"]
    invoice.erp_guid = item["Guid"]
    invoice.external_reference = item["ExternalReference"]
    invoice.customer = Customer.find_by(erp_guid: item["ContactGuid"])
    invoice.invoice_number = item["Number"]
    invoice.currency = item["Currency"]
    invoice.state = item["State"]
    invoice.mail_out_state = item["MailOutState"]
    invoice.latest_mail_out_type = item["LatestMailOutType"]
    invoice.locale = item["Language"]
    invoice.external_reference = item["ExternalReference"]
    invoice.description = item["Description"]
    invoice.comment = item["Comment"]
    invoice.invoice_date = item["Date"]
    invoice.payment_date = item["PaymentDate"]
    invoice.address = item["Address"]
    invoice.show_lines_incl_vat = item["ShowLinesInclVat"]
    invoice.invoice_template_id = item["InvoiceTemplateId"]
    invoice.contact_guid = item["ContactGuid"]
    invoice.payment_condition_number_of_days = item["PaymentConditionNumberOfDays"]
    invoice.payment_condition_type = item["PaymentConditionType"]
    invoice.reminder_fee = item["ReminderFee"]
    invoice.reminder_interest_rate = item["ReminderInterestRate"]
    invoice.total_excl_vat_in_dkk = item["TotalExclVatInDkk"]
    invoice.total_excl_vat = item["TotalExclVat"]
    invoice.total_incl_vat_in_dkk = item["TotalInclVatInDkk"]
    invoice.total_incl_vat = item["TotalInclVat"]
    invoice.is_mobile_pay_invoice_enabled = item["IsMobilePayInvoiceEnabled"]
    invoice.is_penso_pay_enabled = item["IsPensoPayEnabled"]
    if invoice.save
      Broadcasters::Resource.new(invoice, { controller: "invoices" }).create
    end
  end
end
