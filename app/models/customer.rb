class Customer  < ApplicationRecord
  include Tenantable

  has_many :projects, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :time_materials, dependent: :destroy

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_street, ->(street) { where("street LIKE ?", "%#{street}%") if street.present? }
  scope :by_city, ->(city) { where("city LIKE ?", "%#{city}%") if city.present? }
  scope :by_phone, ->(phone) { where("phone LIKE ?", "%#{phone}%") if phone.present? }
  scope :by_email, ->(email) { where("email LIKE ?", "%#{email}%") if email.present? }
  scope :by_zipcode, ->(zipcode) { where("color LIKE ?", "%#{zipcode}%") if zipcode.present? }
  scope :by_vat_number, ->(vat_number) { where("color LIKE ?", "%#{vat_number}%") if vat_number.present? }
  scope :by_ean_number, ->(ean_number) { where("color LIKE ?", "%#{ean_number}%") if ean_number.present? }

  validates :name, presence: true, uniqueness: { scope: :tenant_id, message: I18n.t("customers.errors.messages.name_exist") }
  validates :vat_number, presence: true, uniqueness: { scope: :tenant_id, message: I18n.t("customers.errors.messages.vat_number_exist") }

  def self.filtered(filter)
    flt = filter.filter

    all
    .by_tenant()
    .by_name(flt["name"])
    .by_street(flt["street"])
    .by_city(flt["city"])
    .by_phone(flt["phone"])
    .by_email(flt["email"])
    # .by_zipcode(flt["zipcode"])
    # .by_ean_number(flt["ean_number"])
  rescue #=> error
    filter.destroy if filter
    all
  end

  def address
    "%s\n%s  %s" % [ street, zipcode, city ]
  end

  def self.form(resource:, editable: true)
    Customers::Form.new resource: resource, editable: editable
  end

  def self.add_from_erp(item)
    return false unless item["Name"].present?
    customer = Customer.find_or_create_by(tenant: Current.tenant, erp_guid: item["ContactGuid"])
    customer.name = item["Name"]
    customer.external_reference = item["ExternalReference"]
    customer.is_person = item["IsPerson"]
    customer.is_member = item["IsMember"]
    customer.is_debitor = item["IsDebitor"]
    customer.is_creditor = item["IsCreditor"]
    customer.street = item["Street"]
    customer.zipcode = item["ZipCode"]
    customer.city = item["City"]
    customer.country_key = item["CountryKey"]
    customer.phone = item["Phone"]
    customer.email = item["Email"]
    customer.webpage = item["Webpage"]
    customer.att_person = item["AttPerson"]
    customer.vat_number = item["VatNumber"]
    customer.ean_number = item["EanNumber"]
    customer.payment_condition_type = item["PaymentConditionType"]
    customer.payment_condition_number_of_days = item["PaymentConditionNumberOfDays"]
    customer.member_number = item["MemberNumber"]
    customer.company_status = item["CompanyStatus"]
    customer.vat_region_key = item["VatRegionKey"]
    customer.invoice_mail_out_option_key = item["InvoiceMailOutOptionKey"]
    if customer.save
       Broadcasters::Resource.new(customer).create
    end
  end
end
