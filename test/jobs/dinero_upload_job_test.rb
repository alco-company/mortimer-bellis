require "test_helper"

class DineroUploadJobTest < ActiveJob::TestCase
  setup do
    user = users(:superadmin)
    sign_in user
  end

  test "should mark tm as 'cannot_be_pushed'" do
    t = tenants(:one)
    d = Date.current
    assert_equal 10, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert_equal 10, TimeMaterial.where(tenant: t, date: ..d, state: 5).count
  end

  test "prepare a line with a product that should mark tm as 'pushed_to_erp'" do
    t = tenants(:two)
    d = Date.current
    time_material = time_materials(:two)
    assert_equal 3, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert time_material.reload.pushed_to_erp?
  end

  test "prepare a line with a product with custom price that should mark tm as 'pushed_to_erp'" do
    t = tenants(:two)
    d = Date.current
    time_material = time_materials(:two_a)
    assert_equal 3, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert time_material.reload.pushed_to_erp?
  end

  test "prepare a line with a product with custom price and discount that should mark tm as 'pushed_to_erp'" do
    t = tenants(:two)
    d = Date.current
    time_material = time_materials(:two_b)
    assert_equal 3, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert time_material.reload.pushed_to_erp?
  end

  test "prepare a line with text that should mark tm as 'pushed_to_erp'" do
    t = tenants(:three)
    d = Date.current
    time_material = time_materials(:three)
    assert_equal 2, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert time_material.reload.pushed_to_erp?
  end

  test "prepare a line with a service that should mark tm as 'pushed_to_erp'" do
    t = tenants(:three)
    d = Date.current
    time_material = time_materials(:four)
    assert_equal 2, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert time_material.reload.pushed_to_erp?
  end

  test "prepare a line with a service on a pretend project that should mark tm as 'pushed_to_erp'" do
    t = tenants(:four)
    d = Date.current
    time_material = time_materials(:five)
    assert_equal 2, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert time_material.reload.pushed_to_erp?
  end

  test "prepare a line with a service on an existing project that should mark tm as 'pushed_to_erp'" do
    t = tenants(:four)
    d = Date.current
    time_material = time_materials(:six)
    assert_equal 2, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert time_material.reload.pushed_to_erp?
  end

  test "prepare a line with a service on overtime that should mark tm as 'pushed_to_erp'" do
    t = tenants(:five)
    d = Date.current
    time_material = time_materials(:seven)
    assert_equal 3, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert time_material.reload.pushed_to_erp?
  end

  test "prepare a line with a service on a separate invoice that should mark tm as 'pushed_to_erp'" do
    t = tenants(:five)
    d = Date.current
    time_material = time_materials(:eight)
    assert_equal 3, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert time_material.reload.pushed_to_erp?
  end

  test "prepare a line with a service with custom rate that should mark tm as 'pushed_to_erp'" do
    t = tenants(:five)
    d = Date.current
    time_material = time_materials(:nine)
    assert_equal 3, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert time_material.reload.pushed_to_erp?
  end

  test "prepare an invoice with one line, and one invoice with two lines tm as 'pushed_to_erp'" do
    t = tenants(:six)
    d = Date.current
    assert_equal 3, TimeMaterial.where(tenant: t, date: ..d).count
    DineroUploadJob.perform_now tenant: t, user: users(:one), date: d, provided_service: "Dinero"
    assert_equal 3, TimeMaterial.where(tenant: t, date: ..d, state: 4).count
    assert_equal 2, TimeMaterial.where(tenant: t, date: ..d, state: 4).distinct.pluck(:erp_guid).count
  end
end
