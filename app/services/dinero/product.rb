class Dinero::Product
  attr_accessor :ds

  def initialize(ds)
    @ds = ds
    # @ds = Dinero::Service.new provided_service: ProvidedService.new(service: "Dinero")
  end

  def process(products)
    products.each do |product|
      data = {
        "productNumber":      product.product_number,
        "name":               product.name,
        "baseAmountValue":    product.base_amount_value.to_f,
        "quantity":           product.quantity.to_f,
        "accountNumber":      product.account_number.to_i,
        "unit":               product.unit,
        "externalReference":  nil,
        "comment":            nil
      }
      result = ds.create_product(params: data)
      if result[:ok].present?
        product.update transmit_log: "", erp_guid: result[:ok]["ProductGuid"]
      else
        product.update transmit_log: result[:error].to_s
        Rails.logger.error("Error creating product: #{result[:error]}")
      end
    end
  end
end
