class Dinero::InvoiceDraft
  attr_accessor :ds, :cid_array, :settings, :invoice_date, :drafts

  def initialize(ds)
    @ds = ds
    # @ds = Dinero::Service.new provided_service: ProvidedService.new(service: "Dinero")
  end

  def process(time_materials, invoice_date = Date.current)
    return if time_materials.empty?
    @cid_array = {}
    @invoice_date = invoice_date.to_date
    return { ok: "no records" } if time_materials.where(date: ..invoice_date).empty?

    # load settings like accounts, company details, more
    load_settings
    records = 0

    unless settings=={}
      # Group time materials by customer and project
      time_materials.each do |resource|
        next unless resource.valid?
        next if resource.pushed_to_erp?
        next unless can_resource_be_pushed?(resource)
        pack_resource_for_push(resource) && records += 1 if resource.is_invoice? && resource.done?
      end
      push_to_erp
    end

    { ok: "%d records drafted" % records }

  rescue => err
    UserMailer.error_report(err.to_s, "Dinero::InvoiceDraft#process").deliver_later
    { error: err.message }
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
    @settings["productForOverTime100"] = ds.provided_service&.product_for_overtime_100 || ""
    @settings["productForMileage"] = ds.provided_service&.product_for_mileage || ""
    # @settings["productForHardware"] = ds.provided_service&.product_for_hardware || ""
  end

  def can_resource_be_pushed?(resource)
    return false unless resource.is_invoice?
    unless resource.values_ready_for_push?
      resource.cannot_be_pushed!
      return false
    end
    true

  rescue => err
    resource.update push_log: "%s\n- - - \n%s\%s" % [ resource.push_log, Time.current.to_s, err.message ]
    resource.cannot_be_pushed!
    UserMailer.error_report(err.to_s, "DineroUpload.can_resource_be_pushed?").deliver_later
  end

  def is_mileage_wrong?(resource)
    (resource.kilometers != resource.odo_to - resource.odo_from) or
    (resource.kilometers < 0) or
    (resource.odo_to < resource.odo_from) or
    (resource.odo_from_time > resource.odo_to_time) or
    (resource.odo_from_time.blank?) or
    (resource.odo_to_time.blank?)
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
        invoice, dinero_lines, project_description, refs, date = find_draft_invoices_for_customer(cid)
        lines.each do |line|
          # Struct.new("Line", :productGuid, :description, :comments, :quantity, :accountNumber, :unit, :discount, :lineType, :baseAmountValue).new(
          dinero_lines << product_line(line, date)
          project_description << set_project_description(project_description, line)
          refs << line.product&.external_reference || ""
        end
        line = lines.first
        dinero_invoice = get_invoice_header(invoice, line, dinero_lines, project_description, refs, date)
        persist_invoice_for_testing(cid, dinero_invoice, lines) if Rails.env.test?

        # happy path = {"Guid"=>"5856516f-5127-4dfc-98a7-52ab7d09e1df", "TimeStamp"=>"0000000080C81AC0"}
        # result = ds.push_invoice test_invoice
        if invoice.nil?
          result = ds.create_invoice(params: dinero_invoice)
        else
          result = ds.update_invoice(guid: invoice["Guid"], params: dinero_invoice)
          result["guid"] = invoice["Guid"] if invoice["Guid"].present?
        end
        unless result["guid"].present?
          lines.each do |line|
            line.update push_log: "%s\n%s" % [ line.push_log, result ]
            line.cannot_be_pushed!
            Broadcasters::Resource.new(line, { controller: "time_materials" }).replace
          end
        else
          lines.each do |line|
            line.pushed_to_erp!
            line.update erp_guid: result["guid"], pushed_erp_timestamp: result["TimeStamp"]
            Broadcasters::Resource.new(line, { controller: "time_materials" }).replace
          end
        end

      rescue => err
        line.update push_log: "%s\n%s" % [ line.push_log, err.message ]
        line.cannot_be_pushed!
        UserMailer.error_report(err.to_s, "DineroUpload.push_to_erp").deliver_later
      end
    end
  end

  def get_invoice_header(invoice, line, dinero_lines, project_description, refs, date)
    return invoice_header(line, date, dinero_lines, refs.join(", "), project_description.compact.join(", ")) if invoice.nil?
    {
      "productLines": dinero_lines,
      "timeStamp": invoice["TimeStamp"]
    }
  end

  def invoice_header(line, date, lines, refs, comment)
    {
      "currency" => "DKK",
      "language" => "da-DK",
      "externalReference" => refs,
      "description" => "Faktura",
      "comment" => comment,
      "date" => date,
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

  # 4 types of lines:
  #
  # 1. Product
  # 2. Service (hours)
  # 3. Product (one offs)
  # 4. Text
  #
  # set invoice date on invoice_item - not created_at
  #
  def product_line(line, date)
    date = line.date.blank? ? date : line.date
    return a_product(line, date) unless line.product_id.blank?
    return a_one_off(line, date) unless line.quantity.blank?
    return a_mileage(line, date) unless line.kilometers.blank?
    return a_text(line, date) unless line.comment.blank?
    service_line(line, date)
  end

  def a_product(line, date)
    q = ("%.2f" % line.quantity.gsub(",", ".")).to_f rescue 0.0
    d = ("%.2f" % line.discount.gsub(",", ".")).to_f rescue 0.0
    p = line.unit_price.blank? ? line.product.base_amount_value : ("%.2f" % line.unit_price.gsub(",", ".")).to_f
    initials = line.user&.initials rescue "-"
    {
      "productGuid" => (line.product.erp_guid rescue raise "Product not found - productGuid"),     #   "102eb2e1-d732-4915-96f7-dac83512f16d",
      "comments" =>    "%s, %s: %s" % [ date, initials, line.comment ],
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
  def a_one_off(line, date)
    q = ("%.2f" % line.quantity.gsub(",", ".")).to_f rescue 0.0
    d = ("%.2f" % line.discount.gsub(",", ".")).to_f rescue 0.0
    p = line.unit_price.blank? ? 0.0 : ("%.2f" % line.unit_price.gsub(",", ".")).to_f
    initials = line.user&.initials rescue "-"
    {
      "productGuid" => nil,
      "description" => line.product_name,
      "comments" =>    "%s, %s: %s" % [ date, initials, line.comment ],
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

  def a_text(line, date)
    initials = line.user&.initials rescue "-"

    {
      "productGuid" => nil,
      "description" => "%s, %s: %s" % [ date, initials, line.comment ],
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

  def a_mileage(line, date)
    nbr = settings["productForMileage"]
    prod = Product.where("product_number like ?", nbr).first
    raise "Product not found %s - set products in Dinero Service" % nbr unless prod
    q = line.kilometers.to_f rescue 0.0
    p = prod.base_amount_value
    initials = line.user&.initials rescue "-"
    {
      "productGuid" => prod.erp_guid,             #   "102eb2e1-d732-4915-96f7-dac83512f16d",
      "comments" =>    "%s, %s: %s" % [ date, initials, line.about ],
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
    UserMailer.error_report(err.to_s, "DineroUpload.mileage_line").deliver_later
    {
      "productGuid" => nil,
      "description" => err.message,
      "lineType" =>    "Text"
    }
  end

  def service_line(line, date)
    nbr = case line.over_time.to_s
    when "0"; settings["productForTime"]
    when "1"; settings["productForOverTime"]
    when "2"; settings["productForOverTime100"]
    end
    prod = Product.where("product_number like ?", nbr).first
    raise "Product not found %s - set products in Dinero Service" % nbr unless prod
    q = line.calc_time_to_decimal
    p = line.rate.blank? ? prod.base_amount_value : ("%.2f" % line.rate.gsub(",", ".")).to_f
    initials = line.user&.initials rescue "-"
    {
      "productGuid" => prod.erp_guid,             #   "102eb2e1-d732-4915-96f7-dac83512f16d",
      "comments" =>    "%s, %s: %s" % [ date, initials, line.about ],
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

  def set_project_description(project_description, line)
    return nil if line.project_name.blank?
    return nil if project_description.include?(line.project_name)
    line.project_name
  end

  def persist_invoice_for_testing(cid, dinero_invoice, lines)
    File.open("tmp/testing/dinero_invoice_#{cid}.json", "w") do |f|
      f.write(dinero_invoice.to_json)
      f.write("\n")
      f.write(lines.to_json)
    end
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

  # return
  # dinero_invoice, dinero_lines, project_description, refs, date
  #
  def find_draft_invoices_for_customer(customer_id)
    contactGuid = Customer.find(customer_id).erp_guid rescue nil
    return [ nil, [], [], [], I18n.l(invoice_date, format: :short_iso) ] if contactGuid.blank?

    # Get all draft invoices from Dinero
    @drafts ||= @ds.pull(
      resource_class: "Invoice",
      all: true,
      pageSize: 500,
      status_filter: "Draft",
      fields: "guid,contactGuid,externalReference",
      just_consume: true
    )

    # Filter drafts to only those for this customer
    draft = drafts&.parsed_response&.dig("Collection")&.select do |invoice|
      invoice["contactGuid"] == contactGuid
    end.first || nil

    invoice = invoice_details(draft) || nil
    dinero_lines = invoice["ProductLines"] rescue []
    project_description = [ draft["comment"] ] rescue []
    refs = [ draft["externalReference"] ] rescue []
    date = draft["date"] rescue I18n.l(invoice_date, format: :short_iso)

    [ invoice, dinero_lines, project_description, refs, date ]
  end

  def invoice_details(invoice)
    invoice = @ds.pull_invoice(guid: invoice["guid"])
  rescue => err
    UserMailer.error_report(err.to_s, "Dinero::InvoiceDraft#invoice_details").deliver_later
    nil
  end
end
