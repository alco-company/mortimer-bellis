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
    resource_class = args[:resource_class]
    startDate = nil
    endDate = nil
    user_time_zone(@user.time_zone) do
      ds = Dinero::Service.new user: @user
      case resource_class.to_s
      when "Customer"; fields="Name,ContactGuid,ExternalReference,IsPerson,Street,ZipCode,City,CountryKey,Phone,Email,Webpage,AttPerson,VatNumber,EanNumber,PaymentConditionType,PaymentConditionNumberOfDays,IsMember,MemberNumber,CompanyStatus,VatRegionKey,IsDebitor,IsCreditor,InvoiceMailOutOptionKey"
      when "Product"; fields="Name,ProductGuid,ProductNumber,Quantity,Unit,AccountNumber,BaseAmountValue,BaseAmountValueInclVat,TotalAmount,TotalAmountInclVat,ExternalReference"
      when "Invoice"; startDate=set_start(args); endDate=set_end(args); fields="Number,Guid,ExternalReference,ContactName,ContactGuid,Date,PaymentDate,Description,Currency,Status,MailOutStatus,LatestMailOutType,TotalExclVatInDkk,TotalInclVatInDkk,TotalExclVat,TotalInclVat"
      when "ProvidedService"; pull_all
      end
      ds.pull resource_class: resource_class, all: true, pageSize: 500, fields: fields, start_date: startDate, end_date: endDate
    end
  end

  def pull_all
    [ Customer, Product, Invoice ].each do |rc|
      SyncErpJob.perform_later tenant: @tenant, user: @user, resource_class: rc
    end
  end

  def set_start(args)
    args[:from_at] || Time.now.beginning_of_month.strftime("%Y-%m-%d")
  end

  def set_end(args)
    args[:to_at] || Time.now.end_of_month.strftime("%Y-%m-%d")
  end
end
