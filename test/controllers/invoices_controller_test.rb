require "test_helper"

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice = invoices(:one)
  end

  test "should get index" do
    get invoices_url
    assert_response :success
  end

  test "should get new" do
    get new_invoice_url
    assert_response :success
  end

  test "should create invoice" do
    assert_difference("Invoice.count") do
      post invoices_url, params: { invoice: { address: @invoice.address, comment: @invoice.comment, contact_guid: @invoice.contact_guid, currency: @invoice.currency, customer_id: @invoice.customer_id, date: @invoice.date, description: @invoice.description, erp_guid: @invoice.erp_guid, external_reference: @invoice.external_reference, invoice_template_id: @invoice.invoice_template_id, is_mobile_pay_invoice_enabled: @invoice.is_mobile_pay_invoice_enabled, is_penso_pay_enabled: @invoice.is_penso_pay_enabled, locale: @invoice.locale, payment_condition_number_of_days: @invoice.payment_condition_number_of_days, payment_condition_type: @invoice.payment_condition_type, reminder_fee: @invoice.reminder_fee, reminder_interest_rate: @invoice.reminder_interest_rate, show_lines_incl_vat: @invoice.show_lines_incl_vat, tenant_id: @invoice.tenant_id } }
    end

    assert_redirected_to invoice_url(Invoice.last)
  end

  test "should show invoice" do
    get invoice_url(@invoice)
    assert_response :success
  end

  test "should get edit" do
    get edit_invoice_url(@invoice)
    assert_response :success
  end

  test "should update invoice" do
    patch invoice_url(@invoice), params: { invoice: { address: @invoice.address, comment: @invoice.comment, contact_guid: @invoice.contact_guid, currency: @invoice.currency, customer_id: @invoice.customer_id, date: @invoice.date, description: @invoice.description, erp_guid: @invoice.erp_guid, external_reference: @invoice.external_reference, invoice_template_id: @invoice.invoice_template_id, is_mobile_pay_invoice_enabled: @invoice.is_mobile_pay_invoice_enabled, is_penso_pay_enabled: @invoice.is_penso_pay_enabled, locale: @invoice.locale, payment_condition_number_of_days: @invoice.payment_condition_number_of_days, payment_condition_type: @invoice.payment_condition_type, reminder_fee: @invoice.reminder_fee, reminder_interest_rate: @invoice.reminder_interest_rate, show_lines_incl_vat: @invoice.show_lines_incl_vat, tenant_id: @invoice.tenant_id } }
    assert_redirected_to invoice_url(@invoice)
  end

  test "should destroy invoice" do
    assert_difference("Invoice.count", -1) do
      delete invoice_url(@invoice)
    end

    assert_redirected_to invoices_url
  end
end
