require "test_helper"

class TimeMaterialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @time_material = time_materials(:one)
  end

  test "should get index" do
    get time_materials_url
    assert_response :success
  end

  test "should get new" do
    get new_time_material_url
    assert_response :success
  end

  test "should create time_material" do
    assert_difference("TimeMaterial.count") do
      post time_materials_url, params: { time_material: { about: @time_material.about, customer: @time_material.customer, customer_id: @time_material.customer_id, date: @time_material.date, discount: @time_material.discount, is_free: @time_material.is_free, is_invoice: @time_material.is_invoice, is_offer: @time_material.is_offer, is_separate: @time_material.is_separate, product: @time_material.product, product_id: @time_material.product_id, project: @time_material.project, project_id: @time_material.project_id, quantity: @time_material.quantity, rate: @time_material.rate, tenant_id: @time_material.tenant_id, time: @time_material.time } }
    end

    assert_redirected_to time_material_url(TimeMaterial.last)
  end

  test "should show time_material" do
    get time_material_url(@time_material)
    assert_response :success
  end

  test "should get edit" do
    get edit_time_material_url(@time_material)
    assert_response :success
  end

  test "should update time_material" do
    patch time_material_url(@time_material), params: { time_material: { about: @time_material.about, customer: @time_material.customer, customer_id: @time_material.customer_id, date: @time_material.date, discount: @time_material.discount, is_free: @time_material.is_free, is_invoice: @time_material.is_invoice, is_offer: @time_material.is_offer, is_separate: @time_material.is_separate, product: @time_material.product, product_id: @time_material.product_id, project: @time_material.project, project_id: @time_material.project_id, quantity: @time_material.quantity, rate: @time_material.rate, tenant_id: @time_material.tenant_id, time: @time_material.time } }
    assert_redirected_to time_material_url(@time_material)
  end

  test "should destroy time_material" do
    assert_difference("TimeMaterial.count", -1) do
      delete time_material_url(@time_material)
    end

    assert_redirected_to time_materials_url
  end
end
