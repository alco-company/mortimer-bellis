require "test_helper"

class InvoiceItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice_item = invoice_items(:one)
  end

  test "should get index" do
    get invoice_items_url
    assert_response :success
  end

  test "should get new" do
    get new_invoice_item_url
    assert_response :success
  end

  test "should create invoice_item" do
    assert_difference("InvoiceItem.count") do
      post invoice_items_url, params: { invoice_item: { account_number: @invoice_item.account_number, base_amount_value: @invoice_item.base_amount_value, base_amount_value_incl_vat: @invoice_item.base_amount_value_incl_vat, comments: @invoice_item.comments, description: @invoice_item.description, discount: @invoice_item.discount, invoice_id: @invoice_item.invoice_id, lineType: @invoice_item.lineType, product_guid: @invoice_item.product_guid, product_id: @invoice_item.product_id, project_id: @invoice_item.project_id, quantity: @invoice_item.quantity, tenant_id: @invoice_item.tenant_id, totalAmount: @invoice_item.totalAmount, totalAmount_incl_vat: @invoice_item.totalAmount_incl_vat, unit: @invoice_item.unit } }
    end

    assert_redirected_to invoice_item_url(InvoiceItem.last)
  end

  test "should show invoice_item" do
    get invoice_item_url(@invoice_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_invoice_item_url(@invoice_item)
    assert_response :success
  end

  test "should update invoice_item" do
    patch invoice_item_url(@invoice_item), params: { invoice_item: { account_number: @invoice_item.account_number, base_amount_value: @invoice_item.base_amount_value, base_amount_value_incl_vat: @invoice_item.base_amount_value_incl_vat, comments: @invoice_item.comments, description: @invoice_item.description, discount: @invoice_item.discount, invoice_id: @invoice_item.invoice_id, lineType: @invoice_item.lineType, product_guid: @invoice_item.product_guid, product_id: @invoice_item.product_id, project_id: @invoice_item.project_id, quantity: @invoice_item.quantity, tenant_id: @invoice_item.tenant_id, totalAmount: @invoice_item.totalAmount, totalAmount_incl_vat: @invoice_item.totalAmount_incl_vat, unit: @invoice_item.unit } }
    assert_redirected_to invoice_item_url(@invoice_item)
  end

  test "should destroy invoice_item" do
    assert_difference("InvoiceItem.count", -1) do
      delete invoice_item_url(@invoice_item)
    end

    assert_redirected_to invoice_items_url
  end
end
