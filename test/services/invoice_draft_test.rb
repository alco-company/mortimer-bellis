require "test_helper"

class InvoiceDraftTest < ActiveSupport::TestCase
  test "draft no invoices unless any TimeMaterial posts there" do
    date = time_materials.pluck(:date).max
    time_materials = TimeMaterial.where(tenant: time_materials(:one).tenant, date: ..date)
    # same test as if none existed
    # we have more to test - hence the reverse test
    assert_not time_materials.empty?

    ps = provided_services(:one)
    result = ps.service.classify.constantize.new(provided_service: ps)
      .process(type: :invoice_draft, data: { date: 5.days.ago, records: time_materials.order(:customer_id) })

    assert ({ ok: "none records" }) == result
  end

  test "draft invoices if any TimeMaterial posts there" do
    date = time_materials.pluck(:date).max
    time_materials = TimeMaterial.where(tenant: time_materials(:two).tenant)

    ps = provided_services(:one)
    result = ps.service.classify.constantize.new(provided_service: ps)
      .process(type: :invoice_draft, data: { date: date, records: time_materials.order(:customer_id) })

    assert ({ ok: "%s records drafted" % time_materials.count }) == result
  end

  test "only draft valid invoices if any TimeMaterial posts there" do
    date = time_materials.pluck(:date).max
    time_materials = TimeMaterial.where(tenant: time_materials(:one).tenant)

    ps = provided_services(:one)
    result = ps.service.classify.constantize.new(provided_service: ps)
      .process(type: :invoice_draft, data: { date: date, records: time_materials.order(:customer_id) })

    assert ({ ok: "0 records drafted" }) == result
  end
end
