class TimeMaterialsController < BaseController
  def set_resource
    @resource = InvoiceItem.new
  end
end
