class DineroUploadJob < ApplicationJob
  queue_as :default

  attr_accessor :cid_array

  # args: tenant, user, date
  #
  def perform(**args)
    super(**args)
    @cid_array = {}
    switch_locale do
      @until_date = args[:date]
      time_materials = TimeMaterial.where(tenant: args[:tenant], date: ..@until_date)
      return if time_materials.empty?

      process time_materials.order(:customer_id)
    end
  end

  def process(time_materials)
    time_materials.each do |resource|
      can_resource_be_pushed? resource
      pack_resources(resource) if resource.is_invoice? && resource.done?
    end
    push_to_erp
  end

  def can_resource_be_pushed?(resource)
    return unless resource.is_invoice?
    resource.customer.name                            # check if customer exists/association set correctly
    if resource.quantity.blank?
      return if (resource.time =~ /^\d*[,.]?\d*$/).nil?
      return if (resource.rate =~ /^\d*[,.]?\d*$/).nil?
    else
      resource.product.name   # check if product exists/association set correctly
      return if (resource.quantity =~ /^\d*[,.]?\d*$/).nil?
      return if !resource.unit_price.blank? && (resource.unit_price =~ /^\d*[,.]?\d*$/).nil?
      return if !resource.discount.blank? && (resource.discount =~ /^\d*[,.]?\d*[ ]*%?$/).nil?
    end
    !resource.project_name.blank? && resource.project.name
    resource.done!
  rescue
    resource.cannot_be_pushed!
  end

  def pack_resources(resource)
    if resource.is_separate?
      cid_array[resource.customer_id.to_s + DateTime.current.to_s] = [ resource ]
    else
      cid_array[resource.customer_id] = [] unless cid_array[resource.customer_id]
      cid_array[resource.customer_id] << resource
    end
  end

  def push_to_erp
    cid_array.each do |cid, lines|
      dinero_lines = []
      lines.each do |line|
        # Struct.new("Line", :productGuid, :description, :comments, :quantity, :accountNumber, :unit, :discount, :lineType, :baseAmountValue).new(
        dinero_lines << product_line(line)
      end
      line = lines.first
      dinero_invoice = invoice_header(line, dinero_lines)
      ds = DineroService.new

      # happy path = {"Guid"=>"5856516f-5127-4dfc-98a7-52ab7d09e1df", "TimeStamp"=>"0000000080C81AC0"}
      # result = ds.push_invoice test_invoice
      result = ds.push_invoice dinero_invoice
      debugger
      if result["Guid"]
        lines.each do |line|
          line.pushed_to_erp!
          line.update erp_guid: result["Guid"], pushed_erp_timestamp: result["TimeStamp"]
          Broadcasters::Resource.new(line).replace
        end
      end
    end
  rescue  => error
    say "Error: #{error}"
  end

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

  def product_line(line)
    if line.product_id.blank?
      nbr = line.overtime? ? "a1-timer" : "a-timer"
      prod = Product.where("product_number like ?", nbr).first
      raise "Product not found %s" % nbr unless prod
      {
        "productGuid" => prod.erp_guid,     #   "102eb2e1-d732-4915-96f7-dac83512f16d",
        # "description" => line.about,                # line.product_name if(line.product_id.blank?),
        # "comments" =>    line.comment,
        "quantity" =>    "%.2f" % line.quantity.to_f,
        "accountNumber" => prod.account_number,
        "unit" =>        prod.unit,
        "discount" =>    "%.2f" % line.discount.gsub("%", "").to_f,
        "lineType" =>    "Product",                 # or Text - in which case only description should be set
        "baseAmountValue" => "%.2f" % prod.base_amount_value.to_f
      }
    else
      {
        "productGuid" => (line.product.erp_guid rescue raise "Product not found - productGuid"),     #   "102eb2e1-d732-4915-96f7-dac83512f16d",
        # "description" => line.about,                # line.product_name if(line.product_id.blank?),
        # "comments" =>    line.comment,
        "quantity" =>    line.quantity,
        "accountNumber" => (line.product.account_number rescue raise "Product not found - accountNumber"),
        "unit" =>        (line.product.unit rescue raise "Product not found - unit"),
        "discount" =>    "%.2f" % line.discount.to_f,
        "lineType" =>    "Product",                 # or Text - in which case only description should be set
        "baseAmountValue" => "%.2f" % line.unit_price.to_f
      }
    end
  end

  def invoice_header(line, lines)
    {
      "currency" => "DKK",
      "language" => "da-DK",
      "externalReference" => "123456",
      "description" => "Faktura",
      "comment" => line.comment,
      "date" => I18n.l(@until_date, format: :short_iso),
      "productLines" => lines,
      "address" => line.customer.address,
      "guid" => nil,                                  # "3a315ad3-ddcc-419d-9fc5-219280ae4816",
      "showLinesInclVat" => false,
      "invoiceTemplateId" => nil,                     # "0e2218cf-2209-4a99-926b-e096382f8ef3",
      "contactGuid" => line.customer.erp_guid,        # "f8e8286a-9838-46f7-85c6-080dd48b67f4",
      "paymentConditionNumberOfDays" => line.customer.payment_condition_number_of_days.to_i || 8,
      "paymentConditionType" => line.customer.payment_condition_type || "Netto",
      "reminderFee" => 100,
      "reminderInterestRate" => 0.7,
      "isMobilePayInvoiceEnabled" => false,
      "isPensoPayEnabled" => false
    }
  end
end
