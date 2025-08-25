require "test_helper"

class BatchTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:one)
    @user = users(:one)
    Current.system_user = @user
    @product_ids = Product.by_tenant.where(tenant: @tenant).limit(3).pluck(:id)
    @batch = Batch.create!(tenant: @tenant, user: @user, entity: "Product", all: false, ids: @product_ids.join(","))
  end

  test "entities returns only selected ids when batch_set" do
    rel = Product.by_tenant
    assert_equal @product_ids.sort, @batch.entities(rel).pluck(:id).sort
  end

  test "ids_range reflects min..max of ids list" do
    r = @batch.ids_range
    assert_equal @product_ids.min, r.first
    assert_equal @product_ids.max, r.last
  end

  test "batch_set? true only when persisted and ids present" do
    assert @batch.batch_set?
    empty = Batch.new(tenant: @tenant, user: @user, entity: "Product", all: false, ids: "")
    refute empty.batch_set?
  end

  test "entities returns all when all flag set" do
    @batch.update!(all: true, ids: "")
    rel = Product.by_tenant
    assert_equal rel.count, @batch.entities(rel).count
  end
end
