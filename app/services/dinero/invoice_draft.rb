class Dinero::InvoiceDraft
  attr_accessor :ds, :cid_array, :settings, :invoice_date

  def initialize(ds)
    @ds = ds
    # @ds = DineroService.new provided_service: ProvidedService.new(service: "Dinero")
  end

  def process(time_materials, invoice_date = Date.current)
    # prepare hash to hold customer invoices
    @cid_array = {}
    @invoice_date = invoice_date

    # load settings like accounts, company details, more
    load_settings
    unless settings == {}
      # loop through all time_materials, picking elligible ones
      time_materials.each do |resource|
        next unless resource.valid?
        next if resource.pushed_to_erp?
        can_resource_be_pushed? resource
        pack_resource_for_push(resource) if resource.is_invoice? && resource.done?
      end
      push_to_erp
    end
  end

  # # /sales/settings
  # {
  #   "linesInclVat": false,
  #   "defaultAccountNumber": 1000,
  #   "invoiceTemplateId": "0e2218cf-2209-4a99-926b-e096382f8ef3",
  #   "reminderFee": 0,
  #   "reminderInterestRate": 0,
  #   "trustPilotEmail": "string"
  # }
  #
  def load_settings
    @settings = ds.get_invoice_settings
    return if settings == {}
    @settings["defaultAccountNumber"] = ds.provided_service&.account_for_one_off.to_i || @settings["defaultAccountNumber"]
    @settings["productForTime"] = ds.provided_service&.product_for_time || ""
    @settings["productForOverTime"] = ds.provided_service&.product_for_overtime || ""
  end

  def can_resource_be_pushed?(resource)
    return unless resource.is_invoice?

    resource.customer.name                            # check if customer exists/association set correctly
    if resource.quantity.blank?
      raise "quantity not correct format" if (resource.time =~ /^\d*[,.]?\d*$/).nil? and resource.comment.blank?
      raise "rate not correct format" if !resource.rate.blank? and (resource.rate =~ /^\d*[,.]?\d*$/).nil? and resource.comment.blank?
      raise "time and quantity cannot both be blank" if resource.time.blank? and resource.comment.blank?
      raise "time not correct format" if !resource.time.blank? and (resource.time =~ /^\d*[,.]?\d*$/).nil?
    else
      raise "time and quantity cannot both be set" if !resource.time.blank?
      raise "rate cannot be set if product and quantity is set!" if !resource.rate.blank? && !resource.product_id.blank?
      raise "product_name cannot be blank if quantity is not blank!" if resource.product_name.blank?          # with one off's we use the product text as description! No need to check resource.product.name   # check if product exists/association set correctly
      raise "quantity not correct format" if (resource.quantity =~ /^\d*[,.]?\d*$/).nil?
      raise "unit_price not correct format" if !resource.unit_price.blank? && (resource.unit_price =~ /^\d*[,.]?\d*$/).nil?
      raise "discount not correct format" if !resource.discount.blank? && (resource.discount =~ /^\d*[,.]?\d*[ ]*%?$/).nil?
      raise "not service, product, or text - what is this?" if resource.product.nil? && resource.product_name.blank? && resource.comment.blank?
    end
    # we'll use the project field for adding a comment in the top of the invoice
    # or use the project.name !resource.project_name.blank? && resource.project.name
    resource.done!

  rescue => err
    resource.update push_log: "%s\n%s" % [ resource.push_log, err.message ]
    resource.cannot_be_pushed!
    UserMailer.error_report(err.to_s, "DineroUpload.can_resource_be_pushed?").deliver_later
  end

  #
  # here we pack invoice items for each customer
  # either by customer_id or by customer_id + project_name or
  # separately b/c the item is marked as separate
  #
  def pack_resource_for_push(resource)
    if resource.is_separate?
      cid_array[resource.customer_id.to_s + DateTime.current.to_s] = [ resource ]
    else
      pn = resource.project&.name || resource.project_name || ""
      if !pn.blank?
        cid_array[resource.customer_id.to_s + pn] = [] unless cid_array[resource.customer_id.to_s + pn]
        cid_array[resource.customer_id.to_s + pn] << resource
      else
        cid_array[resource.customer_id] = [] unless cid_array[resource.customer_id]
        cid_array[resource.customer_id] << resource
      end
    end
  end

  def push_to_erp
    cid_array.each do |cid, lines|
      begin
        dinero_lines = []
        project_description = []
        refs = []
        lines.each do |line|
          # Struct.new("Line", :productGuid, :description, :comments, :quantity, :accountNumber, :unit, :discount, :lineType, :baseAmountValue).new(
          dinero_lines << product_line(line)
          project_description << line.project_name || ""
          refs << line.product&.external_reference || ""
        end
        line = lines.first
        dinero_invoice = invoice_header(line, dinero_lines, refs.join(", "), project_description.join(", "))

        # happy path = {"Guid"=>"5856516f-5127-4dfc-98a7-52ab7d09e1df", "TimeStamp"=>"0000000080C81AC0"}
        # result = ds.push_invoice test_invoice
        result = ds.push_invoice dinero_invoice unless dinero_invoice == {}
        raise "Error trying to push invoice: #{result}" unless result["Guid"]

        lines.each do |line|
          line.pushed_to_erp!
          line.update erp_guid: result["Guid"], pushed_erp_timestamp: result["TimeStamp"]
          Broadcasters::Resource.new(line).replace
        end

      rescue => err
        line.update push_log: "%s\n%s" % [ line.push_log, err.message ]
        line.cannot_be_pushed!
        UserMailer.error_report(err.to_s, "DineroUpload.push_to_erp").deliver_later
      end
    end
  end

  # 4 types of lines:
  #
  # 1. Product
  # 2. Service (hours)
  # 3. Product (one offs)
  # 4. Text
  #
  def product_line(line)
    return a_product(line) unless line.product_id.blank?
    return a_one_off(line) unless line.quantity.blank?
    return a_text(line) unless line.comment.blank?
    service_line(line)
  end

  def invoice_header(line, lines, refs, comment)
    {
      "currency" => "DKK",
      "language" => "da-DK",
      "externalReference" => refs,
      "description" => "Faktura",
      "comment" => comment,
      "date" => I18n.l(invoice_date, format: :short_iso),
      "productLines" => lines,
      "address" => line.customer.address,
      "guid" => nil,                                  # "3a315ad3-ddcc-419d-9fc5-219280ae4816",
      "showLinesInclVat" => settings["linesInclVat"],
      "invoiceTemplateId" => settings["invoiceTemplateId"],                     # "0e2218cf-2209-4a99-926b-e096382f8ef3",
      "contactGuid" => line.customer.erp_guid,        # "f8e8286a-9838-46f7-85c6-080dd48b67f4",
      "paymentConditionNumberOfDays" => line.customer.payment_condition_number_of_days.to_i || 8,
      "paymentConditionType" => line.customer.payment_condition_type || "Netto",
      "reminderFee" => settings["reminderFee"],
      "reminderInterestRate" => settings["reminderInterestRate"],
      "isMobilePayInvoiceEnabled" => false,
      "isPensoPayEnabled" => false
    }
  rescue => err
    line.update push_log: "%s\n%s" % [ line.push_log, err.message ]
    line.cannot_be_pushed!
    UserMailer.error_report(err.to_s, "DineroUpload.invoice_header").deliver_later
    {}
  end

  def a_product(line)
    q = ("%.2f" % line.quantity.gsub(",", ".")).to_f rescue 0.0
    d = ("%.2f" % line.discount.gsub(",", ".")).to_f rescue 0.0
    p = line.unit_price.blank? ? line.product.base_amount_value : ("%.2f" % line.unit_price.gsub(",", ".")).to_f

    {
      "productGuid" => (line.product.erp_guid rescue raise "Product not found - productGuid"),     #   "102eb2e1-d732-4915-96f7-dac83512f16d",
      "comments" =>    line.comment,
      "quantity" =>    q,
      "accountNumber" => (line.product.account_number.to_i rescue raise "Product not found - accountNumber"),
      "unit" =>        (line.product.unit rescue raise "Product not found - unit"),
      "discount" =>    d,
      "lineType" =>    "Product",                 # or Text - in which case only description should be set
      "baseAmountValue" => p
    }
  rescue => err
    line.update push_log: "%s\n%s" % [ line.push_log, err.message ]
    line.cannot_be_pushed!
    UserMailer.error_report(err.to_s, "DineroUpload.a_product").deliver_later
    {
      "productGuid" => nil,
      "description" => err.message,
      "lineType" =>    "Text"
    }
  end

  # a product we just invented - no data exists in the system
  def a_one_off(line)
    q = ("%.2f" % line.quantity.gsub(",", ".")).to_f rescue 0.0
    d = ("%.2f" % line.discount.gsub(",", ".")).to_f rescue 0.0
    p = line.unit_price.blank? ? 0.0 : ("%.2f" % line.unit_price.gsub(",", ".")).to_f

    {
      "productGuid" => nil,
      "description" => line.product_name,
      "comments" =>    line.comment,
      "quantity" =>   q,
      "accountNumber" => settings["defaultAccountNumber"].to_i,
      "unit" =>        "parts",
      "discount" =>    d,
      "lineType" =>    "Product",                 # or Text - in which case only description should be set
      "baseAmountValue" => p
    }
  rescue => err
    line.update push_log: "%s\n%s" % [ line.push_log, err.message ]
    line.cannot_be_pushed!
    UserMailer.error_report(err.to_s, "DineroUpload.a_one_off").deliver_later
    {
      "productGuid" => nil,
      "description" => err.message,
      "lineType" =>    "Text"
    }
  end

  def a_text(line)
    {
      "productGuid" => nil,
      "description" => line.comment,
      "lineType" =>    "Text"
    }
  rescue => err
    line.update push_log: "%s\n%s" % [ line.push_log, err.message ]
    line.cannot_be_pushed!
    UserMailer.error_report(err.to_s, "DineroUpload.a_text").deliver_later
    {
      "productGuid" => nil,
      "description" => err.message,
      "lineType" =>    "Text"
    }
  end

  def service_line(line)
    nbr = line.overtime? ? settings["productForOverTime"] : settings["productForTime"]
    prod = Product.where("product_number like ?", nbr).first
    raise "Product not found %s - set products in Dinero Service" % nbr unless prod
    q = line.time.blank? ? 0.25 : ("%.2f" % line.time.gsub(",", ".")).to_f rescue 0.0
    p = line.rate.blank? ? prod.base_amount_value : ("%.2f" % line.rate.gsub(",", ".")).to_f

    {
      "productGuid" => prod.erp_guid,             #   "102eb2e1-d732-4915-96f7-dac83512f16d",
      "comments" =>    line.about,
      "quantity" =>    q,
      "accountNumber" => prod.account_number.to_i,
      "unit" =>        prod.unit,
      "discount" =>    0.0,                       # "%.2f" % line.discount.gsub("%", "").to_f,
      "lineType" =>    "Product",                 # or Text - in which case only description should be set
      "baseAmountValue" => p
    }
  rescue => err
    line.update push_log: "%s\n%s" % [ line.push_log, err.message ]
    line.cannot_be_pushed!
    UserMailer.error_report(err.to_s, "DineroUpload.service_line").deliver_later
    {
      "productGuid" => nil,
      "description" => err.message,
      "lineType" =>    "Text"
    }
  end



  # used for testing the Dinero service initially
  # whd 24/10/2024 - probably not usefull anymore
  #
  def test_invoice
    customer = Customer.first
    prod = Product.where("product_number like 'a-timer'").first
    {
      "currency": "DKK",
      "language": "da-DK",
      "externalReference": "Fx. WebshopSpecialId: 42",
      "description": "Faktura",
      "comment": "Here is a comment",
      "date": "2024-10-22",
      "productLines": [
      {
      "productGuid": prod.erp_guid,
      "comments": "Smells good",
      "quantity": 5,
      "accountNumber": prod.account_number,
      "unit": "parts",
      "discount": 10,
      "lineType": "Product",
      "baseAmountValue": 20
      }, {
      "productGuid": nil,
      "description": "Flowers",
      "comments": "Smells good",
      "quantity": 5,
      "accountNumber": prod.account_number,
      "unit": "parts",
      "discount": 5.5,
      "lineType": "Product",
      "baseAmountValue": 20.25
      }
      ],
      "address": "Test Road 3 2300 Copenhagen S Denmark",
      "guid": nil,
      "showLinesInclVat": false,
      "invoiceTemplateId": nil,
      "contactGuid": customer.erp_guid,
      "paymentConditionNumberOfDays": 8,
      "paymentConditionType": "Netto",
      "reminderFee": 100,
      "reminderInterestRate": 0.7,
      "isMobilePayInvoiceEnabled": false,
      "isPensoPayEnabled": false
    }
  end
end
