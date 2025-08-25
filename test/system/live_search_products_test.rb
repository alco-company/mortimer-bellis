require "application_system_test_case"
require_relative "../test_helpers/system_test_authentication_helper"

class LiveSearchProductsTest < ApplicationSystemTestCase
  include SystemTestAuthenticationHelper

  setup do
    @user = users(:one)
    ui_sign_in @user
    @unique_name = "live-search-#{SecureRandom.hex(3)}"
    Product.create!(tenant: @user.tenant, name: @unique_name, product_number: @unique_name, quantity: 1, unit: 'hours', account_number: 1000, base_amount_value: 10, external_reference: @unique_name)
    visit products_path(search: @unique_name)
    assert_current_path /products/
    assert_text @unique_name
  end

  test "live search filters and restores product" do
    field = find('#search-field')
    # Clear search -> product still present (full list restored)
    field.fill_in(with: '')
    sleep 0.6
    assert_text @unique_name
    # Enter a non-matching term -> product disappears
    field.fill_in(with: 'zzz-no-match')
    sleep 0.6
    refute_text @unique_name
    # Enter prefix -> product reappears
    field.fill_in(with: @unique_name[0,4])
    sleep 0.6
    assert_text @unique_name
  end
end
