require "application_system_test_case"

class TimeMaterialsTest < ApplicationSystemTestCase
  setup do
    @time_material = time_materials(:one)
  end

  test "visiting the index" do
    visit time_materials_url
    assert_selector "h1", text: "Time materials"
  end

  test "should create time material" do
    visit time_materials_url
    click_on "New time material"

    fill_in "About", with: @time_material.about
    fill_in "Customer", with: @time_material.customer
    fill_in "Customer", with: @time_material.customer_id
    fill_in "Date", with: @time_material.date
    fill_in "Discount", with: @time_material.discount
    check "Is free" if @time_material.is_free
    check "Is invoice" if @time_material.is_invoice
    check "Is offer" if @time_material.is_offer
    check "Is separate" if @time_material.is_separate
    fill_in "Product", with: @time_material.product
    fill_in "Product", with: @time_material.product_id
    fill_in "Project", with: @time_material.project
    fill_in "Project", with: @time_material.project_id
    fill_in "Quantity", with: @time_material.quantity
    fill_in "Rate", with: @time_material.rate
    fill_in "Tenant", with: @time_material.tenant_id
    fill_in "Time", with: @time_material.time
    click_on "Create Time material"

    assert_text "Time material was successfully created"
    click_on "Back"
  end

  test "should update Time material" do
    visit time_material_url(@time_material)
    click_on "Edit this time material", match: :first

    fill_in "About", with: @time_material.about
    fill_in "Customer", with: @time_material.customer
    fill_in "Customer", with: @time_material.customer_id
    fill_in "Date", with: @time_material.date
    fill_in "Discount", with: @time_material.discount
    check "Is free" if @time_material.is_free
    check "Is invoice" if @time_material.is_invoice
    check "Is offer" if @time_material.is_offer
    check "Is separate" if @time_material.is_separate
    fill_in "Product", with: @time_material.product
    fill_in "Product", with: @time_material.product_id
    fill_in "Project", with: @time_material.project
    fill_in "Project", with: @time_material.project_id
    fill_in "Quantity", with: @time_material.quantity
    fill_in "Rate", with: @time_material.rate
    fill_in "Tenant", with: @time_material.tenant_id
    fill_in "Time", with: @time_material.time
    click_on "Update Time material"

    assert_text "Time material was successfully updated"
    click_on "Back"
  end

  test "should destroy Time material" do
    visit time_material_url(@time_material)
    click_on "Destroy this time material", match: :first

    assert_text "Time material was successfully destroyed"
  end
end
