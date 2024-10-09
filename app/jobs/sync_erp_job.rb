class SyncErpJob < ApplicationJob
  queue_as :default

  # args:
  #   tenant,
  #   user:
  #   from_at:
  #   to_at:
  #
  def perform(**args)
    super(**args)
    user = args[:user]
    resource_class = args[:resource_class]
    user_time_zone(user.time_zone) do
      ds = DineroService.new
      case resource_class.to_s
      when "Customer"; fields="Name,ContactGuid,Street,ZipCode,City,Phone,Email,VatNumber,EanNumber"
      when "Product"; fields="Name,ProductGuid,ProductNumber,Quantity,Unit,AccountNumber,BaseAmountValue,BaseAmountValueInclVat,TotalAmount,TotalAmountInclVat,ExternalReference"
      when "Invoice"; startDate=set_start(args); endDate=set_end(args); fields="Number,Guid,ExternalReference,ContactName,ContactGuid,Date,PaymentDate,Description,Currency,Status,MailOutStatus,LatestMailOutType,TotalExclVatInDkk,TotalInclVatInDkk,TotalExclVat,TotalInclVat"
      end
      ds.pull resource_class: resource_class, all: true, pageSize: 500, fields: fields, start_date: startDate, end_date: endDate
    end
  end

  def set_start(args)
    args[:from_at] || Time.now.beginning_of_month.strftime("%Y-%m-%d")
  end

  def set_end(args)
    args[:to_at] || Time.now.end_of_month.strftime("%Y-%m-%d")
  end
end
