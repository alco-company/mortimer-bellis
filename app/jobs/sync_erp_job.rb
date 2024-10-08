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
      when "Product"; fields="Name,ProductNumber,Quantity,Unit,AccountNumber,BaseAmountValue,BaseAmountValueInclVat,TotalAmount,TotalAmountInclVat,ExternalReference"
      end
      ds.pull resource_class: resource_class, all: true, pageSize: 500, fields: fields
    end
  end
end
