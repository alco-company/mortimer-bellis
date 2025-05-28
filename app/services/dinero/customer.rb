class Dinero::Customer
  attr_accessor :ds, :cid_array, :settings, :invoice_date, :drafts

  def initialize(ds)
    @ds = ds
    # @ds = Dinero::Service.new provided_service: ProvidedService.new(service: "Dinero")
  end

  def process(customers)
    customers.each do |customer|
      next unless dinero_is_ready_for? customer
      set_payment_condition_type(customer)
      data = {
        "externalReference":            customer.external_reference,
        "name":                         customer.name,
        "street":                       customer.street,
        "zipCode":                      customer.zipcode,
        "city":                         customer.city,
        "countryKey":                   customer.country_key,
        "phone":                        customer.phone,
        "email":                        customer.email,
        "webpage":                      customer.webpage,
        "attPerson":                    nil,
        "vatNumber":                    customer.vat_number,
        "eanNumber":                    nil,
        "seNumber":                     nil,
        "pNumber":                      nil,
        "paymentConditionType":         customer.payment_condition_type,
        "paymentConditionNumberOfDays": customer.payment_condition_number_of_days,
        "isPerson":                     customer.is_person,
        "isMember":                     false,
        "memberNumber":                 nil, # customer.member_number,
        "useCvr":                       !customer.is_person,
        "companyTypeKey":               nil,
        "invoiceMailOutOptionKey":      nil,
        "contactGuid":                  nil
      }
      result = ds.create_customer(params: data)
      if result[:ok].present?
        customer.update transmit_log: "", erp_guid: result[:ok]["ContactGuid"]
      else
        customer.update transmit_log: result[:error].to_s
        Rails.logger.error("Error creating customer: #{result[:error]}")
      end
    end
  end

  # externalReference
  # string or null [ 0 .. 128 ] characters
  # Your external id This can be used for ID'ing in external apps/services e.g. a web shop. The maximum length is 128 characters

  # name
  # required
  # string non-empty
  # Name of the contact person or the company name

  # street
  # string or null
  # Street name

  # zipCode
  # string or null
  # Zip code

  # city
  # string or null
  # City

  # countryKey
  # required
  # string non-empty
  # Country key Two character string e.g. DK for Denmark, DE for Germany or SE for Sweden

  # phone
  # string or null
  # Phone number

  # email
  # string or null
  # Email address

  # webpage
  # string or null
  # Webpage address

  # attPerson
  # string or null
  # Name of the att. person in cases here the contact is a company. If IsPerson this should be NULL.

  # vatNumber
  # string or null
  # VAT number. If IsPerson this should be NULL. This can be used for digital invoicing.

  # eanNumber
  # string or null
  # EAN number. This number is used for digital invoicing. If IsPerson this should be NULL.

  # seNumber
  # string or null
  # SE number. The number is used for digital invoicing. If IsPerson this should be NULL.

  # pNumber
  # string or null
  # P number. The number is used for digital invoicing. If IsPerson this should be NULL.

  # paymentConditionType
  # string or null
  # Type of the payment condition for the contact. Netto, NettoCash or CurrentMonthOut. If NettoCash, then PaymentConditionNumberOfDays should be null. Defaults to type specified in voucher settings.

  # paymentConditionNumberOfDays
  # integer or null <int32>
  # Number of days for payment for the contact. E.g. that the contact has 7 days until payment has to be made. This field depends on PaymentConditionType. If left empty, defaults to the number of days specified in voucher settings.

  # isPerson
  # required
  # boolean
  # Boolean to indicate whether the contact is a private person or a company. If true, the contact is a person.

  # isMember
  # required
  # boolean
  # Boolean to indicate whether the contact is a member. If true, the contact is a member else a private person of a company depending on IsPerson. Only usable by unions.

  # memberNumber
  # string or null
  # A membership number used if the contact is a member. Only usable by unions.

  # useCvr
  # required
  # boolean
  # Boolean to indicate whether the contacts name and address should be updated with data from CVR.

  # companyTypeKey
  # string or null
  # String with the key of the company type. The following keys are allowed: EmptyCompanyType, SoleProprietorship, PrivateLimitedCompany, PublicLimitedCompany, GeneralPartnership, LimitedPartnership, LimitedLiabilityCooperative, LimitedLiabilityVoluntaryAssociation, LimitedLiabilityCompany, EntreprenurLimitedCompany, Union, VoluntaryUnion, SmallPersonallyOwnedCompany, TrustFund and Others.

  # invoiceMailOutOptionKey
  # string or null
  # Preferred e-invoicing method. The possible values are: VAT (cvr-nummer), GLN (ean- / gln-nummer), SE (se-nummer), P (p-nummer) and null if the contact is not a company or if nothing is preferred. Each field requires that the selected mail out number is present - e.g. vat number should be present when InvoiceMailOutOptionKey is set to VAT.

  # contactGuid
  # string or null <uuid>
  # Optional guid for the contact. If not set the system will create a guid returned in the response.
  # The guid is used for updating the contact. If the guid is not set, the system will create a new contact. If the guid is set, the system will update the contact with the given guid. The guid is returned in the response if a new contact is created. The guid is also returned in the response if an existing contact is updated.
  #
  # @param customer [Customer] customer to be processed
  # @return [void]
  #
  def dinero_is_ready_for?(customer)
    # customer.att_person
    # customer.city
    # customer.company_status
    return false unless %w[DK SE DE].include?(customer.country_key)
    # customer.ean_number
    # customer.email
    # customer.erp_guid
    # customer.external_reference
    # customer.hourly_rate
    # customer.invoice_mail_out_option_key
    # customer.is_creditor
    # customer.is_debitor
    # customer.is_member
    # customer.is_person
    # customer.member_number
    return false if customer.name.blank?
    # return false if customer.payment_condition_number_of_days.nil? || !customer.payment_condition_number_of_days.to_i.is_a?(Integer)
    # return false unless %w[Netto NettoCash CurrentMonthOut].include?(customer.payment_condition_type)
    # customer.phone
    # customer.street
    # customer.tenant_id
    # customer.transmit_log
    return false if !customer.is_person && customer.vat_number.blank?
    customer.vat_region_key
    true
  end

  def set_payment_condition_type(customer)
    if %W[Netto NettoCash CurrentMonthOut].include?(customer.payment_condition_type)
      case customer.payment_condition_type
      when "Netto", "CurrentMonthOut"
        begin
          customer.payment_condition_number_of_days = customer.payment_condition_number_of_days.to_i > 0 ?
          customer.payment_condition_number_of_days :
          "1"
        rescue StandardError => e
          customer.payment_condition_number_of_days = "1"
        end
      when "NettoCash"; customer.payment_condition_number_of_days = nil
      end
    else
      customer.payment_condition_type = nil
      customer.payment_condition_number_of_days = nil
    end
  end
end
