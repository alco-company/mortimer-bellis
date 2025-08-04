require "application_system_test_case"

class CustomersTest < ApplicationSystemTestCase
  setup do
    @customer = customers(:one)
    @user = users(:one)
    login_as @user
  end

  test "visiting the index" do
    debugger
    visit customers_url
    assert_selector "h1", text: "Customers"
  end

  test "should create customer" do
    visit customers_url
    click_on "New customer"

    fill_in "City", with: @customer.city
    fill_in "Ean number", with: @customer.ean_number
    fill_in "Email", with: @customer.email
    fill_in "Name", with: @customer.name
    fill_in "Phone", with: @customer.phone
    fill_in "Street", with: @customer.street
    fill_in "Tenant", with: @customer.tenant_id
    fill_in "Vat number", with: @customer.vat_number
    fill_in "Zipcode", with: @customer.zipcode
    click_on "Create Customer"

    assert_text "Customer was successfully created"
    click_on "Back"
  end

  test "should update Customer" do
    visit customer_url(@customer)
    click_on "Edit this customer", match: :first

    fill_in "City", with: @customer.city
    fill_in "Ean number", with: @customer.ean_number
    fill_in "Email", with: @customer.email
    fill_in "Name", with: @customer.name
    fill_in "Phone", with: @customer.phone
    fill_in "Street", with: @customer.street
    fill_in "Tenant", with: @customer.tenant_id
    fill_in "Vat number", with: @customer.vat_number
    fill_in "Zipcode", with: @customer.zipcode
    click_on "Update Customer"

    assert_text "Customer was successfully updated"
    click_on "Back"
  end

  test "should destroy Customer" do
    visit customer_url(@customer)
    click_on "Destroy this customer", match: :first

    assert_text "Customer was successfully destroyed"
  end
end
