require "application_system_test_case"

class InvoicesTest < ApplicationSystemTestCase
  setup do
    @invoice = invoices(:one)
  end

  test "visiting the index" do
    visit invoices_url
    assert_selector "h1", text: "Invoices"
  end

  test "should create invoice" do
    visit invoices_url
    click_on "New invoice"

    fill_in "Address", with: @invoice.address
    fill_in "Comment", with: @invoice.comment
    fill_in "Contact guid", with: @invoice.contact_guid
    fill_in "Currency", with: @invoice.currency
    fill_in "Customer", with: @invoice.customer_id
    fill_in "Date", with: @invoice.date
    fill_in "Description", with: @invoice.description
    fill_in "Erp guid", with: @invoice.erp_guid
    fill_in "External reference", with: @invoice.external_reference
    fill_in "Invoice template", with: @invoice.invoice_template_id
    check "Is mobile pay invoice enabled" if @invoice.is_mobile_pay_invoice_enabled
    check "Is penso pay enabled" if @invoice.is_penso_pay_enabled
    fill_in "Locale", with: @invoice.locale
    fill_in "Payment condition number of days", with: @invoice.payment_condition_number_of_days
    fill_in "Payment condition type", with: @invoice.payment_condition_type
    fill_in "Reminder fee", with: @invoice.reminder_fee
    fill_in "Reminder interest rate", with: @invoice.reminder_interest_rate
    check "Show lines incl vat" if @invoice.show_lines_incl_vat
    fill_in "Tenant", with: @invoice.tenant_id
    click_on "Create Invoice"

    assert_text "Invoice was successfully created"
    click_on "Back"
  end

  test "should update Invoice" do
    visit invoice_url(@invoice)
    click_on "Edit this invoice", match: :first

    fill_in "Address", with: @invoice.address
    fill_in "Comment", with: @invoice.comment
    fill_in "Contact guid", with: @invoice.contact_guid
    fill_in "Currency", with: @invoice.currency
    fill_in "Customer", with: @invoice.customer_id
    fill_in "Date", with: @invoice.date.to_s
    fill_in "Description", with: @invoice.description
    fill_in "Erp guid", with: @invoice.erp_guid
    fill_in "External reference", with: @invoice.external_reference
    fill_in "Invoice template", with: @invoice.invoice_template_id
    check "Is mobile pay invoice enabled" if @invoice.is_mobile_pay_invoice_enabled
    check "Is penso pay enabled" if @invoice.is_penso_pay_enabled
    fill_in "Locale", with: @invoice.locale
    fill_in "Payment condition number of days", with: @invoice.payment_condition_number_of_days
    fill_in "Payment condition type", with: @invoice.payment_condition_type
    fill_in "Reminder fee", with: @invoice.reminder_fee
    fill_in "Reminder interest rate", with: @invoice.reminder_interest_rate
    check "Show lines incl vat" if @invoice.show_lines_incl_vat
    fill_in "Tenant", with: @invoice.tenant_id
    click_on "Update Invoice"

    assert_text "Invoice was successfully updated"
    click_on "Back"
  end

  test "should destroy Invoice" do
    visit invoice_url(@invoice)
    click_on "Destroy this invoice", match: :first

    assert_text "Invoice was successfully destroyed"
  end
end
