class Dinero::Customer
  attr_accessor :ds, :cid_array, :settings, :invoice_date, :drafts

  def initialize(ds)
    @ds = ds
    # @ds = Dinero::Service.new provided_service: ProvidedService.new(service: "Dinero")
  end

  def process(customers)
    customers.each do |customer|
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
        "paymentConditionNumberOfDays": customer.payment_condition_number_of_days.to_i,
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
end
