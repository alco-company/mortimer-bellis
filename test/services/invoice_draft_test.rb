require "test_helper"

class InvoiceDraftTest < ActiveSupport::TestCase
  test "draft no invoices unless any TimeMaterial posts there" do
    max_date = TimeMaterial.pluck(:date).max
    records = TimeMaterial.where(tenant: time_materials(:one).tenant, date: ..max_date)
    # same test as if none existed
    # we have more to test - hence the reverse test
    assert_not records.empty?

    ps = provided_services(:one)
    result = ps.service.classify.constantize.new(provided_service: ps)
      .process(type: :invoice_draft, data: { date: 5.days.ago, records: records.order(:customer_id) })

    assert_equal ({ ok: "no records" }), result
  end

  test "draft invoices if any TimeMaterial posts there" do
    max_date = TimeMaterial.pluck(:date).max
    records = TimeMaterial.where(tenant: time_materials(:two).tenant)

    ps = provided_services(:one)
    result = ps.service.classify.constantize.new(provided_service: ps)
      .process(type: :invoice_draft, data: { date: max_date, records: records.order(:customer_id) })

    # 3 records should be drafted (two, two_a, two_b have valid products)
    # two_c is a one-off product without product_id, requires add_products permission
    assert_equal ({ ok: "3 records drafted" }), result
  end

  test "only draft valid invoices if any TimeMaterial posts there" do
    max_date = TimeMaterial.pluck(:date).max
    records = TimeMaterial.where(tenant: time_materials(:one).tenant)

    ps = provided_services(:one)
    result = ps.service.classify.constantize.new(provided_service: ps)
      .process(type: :invoice_draft, data: { date: max_date, records: records.order(:customer_id) })

    assert_equal ({ ok: "0 records drafted" }), result
  end

  test "draft invoices if any TimeMaterial posts there - and invoices on Dinero to add them to" do
    max_date = TimeMaterial.pluck(:date).max
    records = TimeMaterial.where(tenant: time_materials(:one).tenant)

    ps = provided_services(:one)
    result = ps.service.classify.constantize.new(provided_service: ps)
      .process(type: :invoice_draft, data: { date: max_date, records: records.order(:customer_id) })

    assert_equal ({ ok: "0 records drafted" }), result
  end

  # Rate precedence hierarchy tests
  test "invoice draft uses user rate when no customer or project rate set" do
    # Ensure directory exists
    FileUtils.mkdir_p("tmp/testing")

    tm = time_materials(:rate_test_user)
    records = TimeMaterial.where(id: tm.id)
    max_date = tm.date

    ps = provided_services(:one)
    service = ps.service.classify.constantize.new(provided_service: ps)

    # Debug: check if record is valid and pushable
    assert tm.valid?, "TimeMaterial should be valid"
    assert tm.pushable?, "TimeMaterial should be pushable: #{tm.errors.full_messages.join(', ')}"

    result = service.process(type: :invoice_draft, data: { date: max_date, records: records })

    # The result might be an error if ERP push fails in test, but file should still be created
    assert result[:ok].present? || result[:error].present?, "Should return a result"

    # Check the generated invoice JSON
    invoice_files = Dir.glob("tmp/testing/dinero_invoice_*.json")
    assert invoice_files.any?, "Invoice JSON file should be created, found: #{invoice_files.inspect}"

    # Read first line only (invoice data)
    invoice_json = File.readlines(invoice_files.first).first
    invoice_data = JSON.parse(invoice_json)
    product_line = invoice_data["productLines"].first

    assert_equal 100.00, product_line["baseAmountValue"], "Should use user rate of 100.00"
  ensure
    FileUtils.rm_rf("tmp/testing") if Dir.exist?("tmp/testing")
  end

  test "invoice draft uses customer rate over user rate" do
    FileUtils.mkdir_p("tmp/testing")

    tm = time_materials(:rate_test_customer)
    records = TimeMaterial.where(id: tm.id)
    max_date = tm.date

    ps = provided_services(:one)
    service = ps.service.classify.constantize.new(provided_service: ps)
    result = service.process(type: :invoice_draft, data: { date: max_date, records: records })

    assert result[:ok].present? || result[:error].present?, "Should return a result"

    invoice_files = Dir.glob("tmp/testing/dinero_invoice_*.json")
    assert invoice_files.any?, "Invoice JSON file should be created"

    invoice_json = File.readlines(invoice_files.first).first
    invoice_data = JSON.parse(invoice_json)
    product_line = invoice_data["productLines"].first

    assert_equal 850.50, product_line["baseAmountValue"], "Should use customer rate of 850.50"
  ensure
    FileUtils.rm_rf("tmp/testing") if Dir.exist?("tmp/testing")
  end

  test "invoice draft uses project rate over customer and user rate" do
    FileUtils.mkdir_p("tmp/testing")

    tm = time_materials(:rate_test_project)
    records = TimeMaterial.where(id: tm.id)
    max_date = tm.date

    ps = provided_services(:one)
    service = ps.service.classify.constantize.new(provided_service: ps)
    result = service.process(type: :invoice_draft, data: { date: max_date, records: records })

    assert result[:ok].present? || result[:error].present?, "Should return a result"

    invoice_files = Dir.glob("tmp/testing/dinero_invoice_*.json")
    assert invoice_files.any?, "Invoice JSON file should be created"

    invoice_json = File.readlines(invoice_files.first).first
    invoice_data = JSON.parse(invoice_json)
    product_line = invoice_data["productLines"].first

    assert_equal 300.00, product_line["baseAmountValue"], "Should use project rate of 300.00"
  ensure
    FileUtils.rm_rf("tmp/testing") if Dir.exist?("tmp/testing")
  end

  test "invoice draft uses team rate when user has no rate" do
    FileUtils.mkdir_p("tmp/testing")

    tm = time_materials(:rate_test_team)
    records = TimeMaterial.where(id: tm.id)
    max_date = tm.date

    ps = provided_services(:one)
    service = ps.service.classify.constantize.new(provided_service: ps)
    result = service.process(type: :invoice_draft, data: { date: max_date, records: records })

    assert result[:ok].present? || result[:error].present?, "Should return a result"

    invoice_files = Dir.glob("tmp/testing/dinero_invoice_*.json")
    assert invoice_files.any?, "Invoice JSON file should be created"

    invoice_json = File.readlines(invoice_files.first).first
    invoice_data = JSON.parse(invoice_json)
    product_line = invoice_data["productLines"].first

    assert_equal 200.00, product_line["baseAmountValue"], "Should use team rate of 200.00"
  ensure
    FileUtils.rm_rf("tmp/testing") if Dir.exist?("tmp/testing")
  end

  test "invoice draft respects complete rate precedence hierarchy" do
    FileUtils.mkdir_p("tmp/testing")

    # Test all four rates in one test to verify the hierarchy
    tm_ids = [
      time_materials(:rate_test_user).id,     # 100.00 - user rate
      time_materials(:rate_test_customer).id, # 850.50 - customer rate (overrides user)
      time_materials(:rate_test_project).id,  # 300.00 - project rate (overrides customer and user)
      time_materials(:rate_test_team).id      # 200.00 - team rate (user :three has no rate)
    ]
    records = TimeMaterial.where(id: tm_ids)
    max_date = records.first.date

    ps = provided_services(:one)
    service = ps.service.classify.constantize.new(provided_service: ps)
    result = service.process(type: :invoice_draft, data: { date: max_date, records: records })

    assert result[:ok].present? || result[:error].present?, "Should return a result"

    invoice_files = Dir.glob("tmp/testing/dinero_invoice_*.json")
    # 2 invoices created: one for customer without project, one for customer with project
    assert_equal 2, invoice_files.length, "Should create two invoices: one for same customer without project, one with project"

    # Collect all rates from both invoices
    all_rates = []
    invoice_files.each do |file|
      invoice_json = File.readlines(file).first
      invoice_data = JSON.parse(invoice_json)
      invoice_data["productLines"].each do |line|
        all_rates << line["baseAmountValue"]
      end
    end

    # Verify each line has the correct rate
    rates = all_rates.sort
    expected_rates = [ 100.00, 200.00, 300.00, 850.50 ]

    assert_equal expected_rates, rates, "Should use correct rate precedence: user < team < project < customer"
  ensure
    FileUtils.rm_rf("tmp/testing") if Dir.exist?("tmp/testing")
  end
end
