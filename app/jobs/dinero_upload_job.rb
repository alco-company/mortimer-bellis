class DineroUploadJob < ApplicationJob
  queue_as :default

  # args: tenant, user, date
  #
  def perform(**args)
    super(**args)
    switch_locale do
      @until_date = args[:date]
      time_materials = TimeMaterial.where(tenant: args[:tenant], date: ..@until_date)
      return if time_materials.empty?

      ps = ProvidedService.find_by(name: args[:provided_service])
      ps.service.classify.constantize.new(provided_service: ps)
        .process(type: :invoice_draft, data: time_materials.order(:customer_id))
    end
  end
end
