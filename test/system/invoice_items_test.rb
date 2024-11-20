require "application_system_test_case"

class InvoiceItemsTest < ApplicationSystemTestCase
  setup do
    @invoice_item = invoice_items(:one)
  end

  test "visiting the index" do
    visit invoice_items_url
    assert_selector "h1", text: "Invoice items"
  end

  test "should create invoice item" do
    visit invoice_items_url
    click_on "New invoice item"

    fill_in "account_number", with: @invoice_item.account_number
    fill_in "base_amount_value", with: @invoice_item.base_amount_value
    fill_in "base_amount_value_incl_vat", with: @invoice_item.base_amount_value_incl_vat
    fill_in "Comments", with: @invoice_item.comments
    fill_in "Description", with: @invoice_item.description
    fill_in "Discount", with: @invoice_item.discount
    fill_in "Invoice", with: @invoice_item.invoice_id
    fill_in "Linetype", with: @invoice_item.lineType
    fill_in "Product guid", with: @invoice_item.product_guid
    fill_in "Product", with: @invoice_item.product_id
    fill_in "Project", with: @invoice_item.project_id
    fill_in "Quantity", with: @invoice_item.quantity
    fill_in "Tenant", with: @invoice_item.tenant_id
    fill_in "Totalamount", with: @invoice_item.totalAmount
    fill_in "Totalamount_incl_vat", with: @invoice_item.totalAmount_incl_vat
    fill_in "Unit", with: @invoice_item.unit
    click_on "Create Invoice item"

    assert_text "Invoice item was successfully created"
    click_on "Back"
  end

  test "should update Invoice item" do
    visit invoice_item_url(@invoice_item)
    click_on "Edit this invoice item", match: :first

    fill_in "account_number", with: @invoice_item.account_number
    fill_in "base_amount_value", with: @invoice_item.base_amount_value
    fill_in "base_amount_value_incl_vat", with: @invoice_item.base_amount_value_incl_vat
    fill_in "Comments", with: @invoice_item.comments
    fill_in "Description", with: @invoice_item.description
    fill_in "Discount", with: @invoice_item.discount
    fill_in "Invoice", with: @invoice_item.invoice_id
    fill_in "Linetype", with: @invoice_item.lineType
    fill_in "Product guid", with: @invoice_item.product_guid
    fill_in "Product", with: @invoice_item.product_id
    fill_in "Project", with: @invoice_item.project_id
    fill_in "Quantity", with: @invoice_item.quantity
    fill_in "Tenant", with: @invoice_item.tenant_id
    fill_in "Totalamount", with: @invoice_item.totalAmount
    fill_in "Totalamount_incl_vat", with: @invoice_item.totalAmount_incl_vat
    fill_in "Unit", with: @invoice_item.unit
    click_on "Update Invoice item"

    assert_text "Invoice item was successfully updated"
    click_on "Back"
  end

  test "should destroy Invoice item" do
    visit invoice_item_url(@invoice_item)
    click_on "Destroy this invoice item", match: :first

    assert_text "Invoice item was successfully destroyed"
  end
end
