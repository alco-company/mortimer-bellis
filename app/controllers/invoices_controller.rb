class InvoicesController < MortimerController
  # {
  # "currency": "DKK",
  # "language": "en-GB",
  # "externalReference": "Fx. WebshopSpecialId: 42",
  # "description": "Description of document type. Fx.: invoice, credit note or offer",
  # "comment": "Here is a comment",
  # "date": "2022-06-01",
  # "productLines": [
  # {
  # "productGuid": "102eb2e1-d732-4915-96f7-dac83512f16d",
  # "description": "Flowers",
  # "comments": "Smells good",
  # "quantity": 5,
  # "accountNumber": 1000,
  # "unit": "parts",
  # "discount": 10,
  # "lineType": "Product",
  # "baseAmountValue": 20
  # }
  # ],
  # "address": "Test Road 3 2300 Copenhagen S Denmark",
  # "guid": "3a315ad3-ddcc-419d-9fc5-219280ae4816",
  # "showLinesInclVat": false,
  # "invoiceTemplateId": "0e2218cf-2209-4a99-926b-e096382f8ef3",
  # "contactGuid": "f8e8286a-9838-46f7-85c6-080dd48b67f4",
  # "paymentConditionNumberOfDays": 8,
  # "paymentConditionType": "Netto",
  # "reminderFee": 100,
  # "reminderInterestRate": 0.7,
  # "isMobilePayInvoiceEnabled": true,
  # "isPensoPayEnabled": true
  # }
  def push_to_erp
  end


  # {
  #   "PaymentDate"=>"2024-10-15",
  #   "PaymentStatus"=>"Booked",
  #   "PaymentConditionNumberOfDays"=>14,
  #   "PaymentConditionType"=>"Netto",
  #   "FikCode"=>"+71<000118244219861+89675219<",
  #   "DepositAccountNumber"=>55000,
  #   "MailOutStatus"=>"Sent",
  #   "LatestMailOutType"=>"Mailout",
  #   "IsSentToDebtCollection"=>false,
  #   "IsMobilePayInvoiceEnabled"=>false,
  #   "IsPensoPayEnabled"=>false,
  #   "Status"=>"Booked",
  #   "ContactGuid"=>"6e411607-daa4-4a26-82a5-1913b2161ba6",
  #   "Guid"=>"35a4f9bc-6b81-4a28-b641-d8f0fe7c7cd2",
  #   "TimeStamp"=>"000000007EE1C39C",
  #   "CreatedAt"=>"2024-10-01T03:02:04.12",
  #   "UpdatedAt"=>"2024-10-01T03:02:05.357",
  #   "DeletedAt"=>nil,
  #   "Number"=>21986,
  #   "ContactName"=>"ØSTERILD GRUSVÆRK ApS",
  #   "ShowLinesInclVat"=>false,
  #   "TotalExclVat"=>255.0,
  #   "TotalVatableAmount"=>255.0,
  #   "TotalInclVat"=>318.75,
  #   "TotalNonVatableAmount"=>0.0,
  #   "TotalVat"=>63.75,
  #   "TotalLines"=>[
  #     {"Type"=>"SubTotal", "TotalAmount"=>255.0, "Position"=>0, "Label"=>"Subtotal"},
  #     {"Type"=>"Vat", "TotalAmount"=>63.75, "Position"=>1, "Label"=>"Moms (25,00%)"},
  #     {"Type"=>"Total", "TotalAmount"=>318.75, "Position"=>2, "Label"=>"Total DKK"}
  #   ],
  #   "InvoiceTemplateId"=>"9571f1b3-df6b-42ed-8165-5ceb9256db68",
  #   "Currency"=>"DKK",
  #   "Language"=>"da-DK",
  #   "ExternalReference"=>nil,
  #   "Description"=>"Faktura",
  #   "Comment"=>"",
  #   "Date"=>"2024-10-01",
  #   "ProductLines"=> [
  #     {
  #       "AccountName"=>"Salg af varer/ydelser m/moms",
  #       "BaseAmountValue"=>180.0,
  #       "BaseAmountValueInclVat"=>225.0,
  #       "TotalAmount"=>180.0,
  #       "TotalAmountInclVat"=>225.0,
  #       "ProductGuid"=>"32738ba0-3a93-4a46-8143-18ed139ea3c4",
  #       "Description"=>"dns-abon - DNS abon kvt",
  #       "Comments"=>"gert-agesen.dk",
  #       "Quantity"=>1.0,
  #       "AccountNumber"=>1000,
  #       "Unit"=>"parts",
  #       "Discount"=>0.0,
  #       "LineType"=>"Product"
  #     }, {
  #       "AccountName"=>"Salg af varer/ydelser m/moms",
  #       "BaseAmountValue"=>75.0,
  #       "BaseAmountValueInclVat"=>93.75,
  #       "TotalAmount"=>75.0,
  #       "TotalAmountInclVat"=>93.75,
  #       "ProductGuid"=>"d5f11e0c-0775-4caa-ba9a-83e50539c5e4",
  #       "Description"=>"pbox-250 - Personlig postkasse 250 mb",
  #       "Comments"=>nil,
  #       "Quantity"=>1.0,
  #       "AccountNumber"=>1000,
  #       "Unit"=>"parts",
  #       "Discount"=>0.0,
  #       "LineType"=>"Product"
  #     }
  #   ],
  #   "Address"=>"Bromøllevej 15\n7700 Thisted\nCvr-nr.: DK16177482"
  # }
  def show
    if @resource.invoice_items.empty?
      json = Dinero::Service.new.pull_invoice guid: @resource.erp_guid
      json["ProductLines"].each do |item|
        InvoiceItem.add_from_erp item, @resource, resource: @resource
      end
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(invoice: [ :tenant_id,
        :customer_id,
        :project_id,
        :currency,
        :invoice_number,
        :currency,
        :state,
        :mail_out_state,
        :latest_mail_out_type,
        :locale,
        :external_reference,
        :description,
        :comment,
        :invoice_date,
        :payment_date,
        :address,
        :erp_guid,
        :show_lines_incl_vat,
        :invoice_template_id,
        :contact_guid,
        :payment_condition_number_of_days,
        :payment_condition_type,
        :reminder_fee,
        :reminder_interest_rate,
        :total_excl_vat_in_dkk,
        :total_excl_vat,
        :total_incl_vat_in_dkk,
        :total_incl_vat,
        :is_mobile_pay_invoice_enabled,
        :is_penso_pay_enabled
      ])
    end
end
