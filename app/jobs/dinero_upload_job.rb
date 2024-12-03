class DineroUploadJob < ApplicationJob
  queue_as :default

  # args: tenant, user, date
  #
  def perform(**args)
    super(**args)
    switch_locale do
      @until_date = args[:date]
      time_materials = TimeMaterial.by_tenant.where(date: ..@until_date)
      return if time_materials.empty?

      ps = ProvidedService.by_tenant.find_by(name: args[:provided_service])
      ps.service.classify.constantize.new(provided_service: ps)
        .process(type: :invoice_draft, data: { records: time_materials.order(:customer_id), date: @until_date }) if ps
    end
  end
end
