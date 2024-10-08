require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { account_number: @product.account_number, base_amount_value: @product.base_amount_value, base_amount_value_incl_vat: @product.base_amount_value_incl_vat, erp_guid: @product.erp_guid, external_reference: @product.external_reference, name: @product.name, product_number: @product.product_number, quantity: @product.quantity, tenant_id: @product.tenant_id, total_amount: @product.total_amount, total_amount_incl_vat: @product.total_amount_incl_vat, unit: @product.unit } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: { product: { account_number: @product.account_number, base_amount_value: @product.base_amount_value, base_amount_value_incl_vat: @product.base_amount_value_incl_vat, erp_guid: @product.erp_guid, external_reference: @product.external_reference, name: @product.name, product_number: @product.product_number, quantity: @product.quantity, tenant_id: @product.tenant_id, total_amount: @product.total_amount, total_amount_incl_vat: @product.total_amount_incl_vat, unit: @product.unit } }
    assert_redirected_to product_url(@product)
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end
end
