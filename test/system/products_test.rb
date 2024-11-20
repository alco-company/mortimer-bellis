require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
  end

  test "visiting the index" do
    visit products_url
    assert_selector "h1", text: "Products"
  end

  test "should create product" do
    visit products_url
    click_on "New product"

    fill_in "Account number", with: @product.account_number
    fill_in "Base amount value", with: @product.base_amount_value
    fill_in "Base amount value incl vat", with: @product.base_amount_value_incl_vat
    fill_in "Erp guid", with: @product.erp_guid
    fill_in "External reference", with: @product.external_reference
    fill_in "Name", with: @product.name
    fill_in "Product number", with: @product.product_number
    fill_in "Quantity", with: @product.quantity
    fill_in "Tenant", with: @product.tenant_id
    fill_in "Total amount", with: @product.total_amount
    fill_in "Total amount incl vat", with: @product.total_amount_incl_vat
    fill_in "Unit", with: @product.unit
    click_on "Create Product"

    assert_text "Product was successfully created"
    click_on "Back"
  end

  test "should update Product" do
    visit product_url(@product)
    click_on "Edit this product", match: :first

    fill_in "Account number", with: @product.account_number
    fill_in "Base amount value", with: @product.base_amount_value
    fill_in "Base amount value incl vat", with: @product.base_amount_value_incl_vat
    fill_in "Erp guid", with: @product.erp_guid
    fill_in "External reference", with: @product.external_reference
    fill_in "Name", with: @product.name
    fill_in "Product number", with: @product.product_number
    fill_in "Quantity", with: @product.quantity
    fill_in "Tenant", with: @product.tenant_id
    fill_in "Total amount", with: @product.total_amount
    fill_in "Total amount incl vat", with: @product.total_amount_incl_vat
    fill_in "Unit", with: @product.unit
    click_on "Update Product"

    assert_text "Product was successfully updated"
    click_on "Back"
  end

  test "should destroy Product" do
    visit product_url(@product)
    click_on "Destroy this product", match: :first

    assert_text "Product was successfully destroyed"
  end
end
