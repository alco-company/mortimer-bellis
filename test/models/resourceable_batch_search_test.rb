require "test_helper"

class ResourceableBatchSearchTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:one)
    @user = users(:one)
    Current.system_user = @user
    @hours      = products(:hours)
    @overhours  = products(:overhours)
  end

  def build_records(params_hash, batch)
    # Mirror Resourceable pipeline manually
    collection = Product.by_tenant
    collection = batch.entities(collection) if batch&.batch_set?
    collection = params_hash[:search] ? collection.by_fulltext(params_hash[:search]) : collection
    collection.order(id: :desc)
  end

  test "search is restricted to selected ids when batch all=false" do
    batch = Batch.create!(tenant: @tenant, user: @user, entity: "Product", all: false, ids: @hours.id.to_s)

    records = build_records({ search: @overhours.product_number[0, 4] }, batch)
    assert_empty records

    records = build_records({ search: @hours.product_number[0, 3] }, batch)
    assert_equal [ @hours.id ], records.pluck(:id)
  end

  test "search applies to full scope when batch all=true" do
    batch = Batch.create!(tenant: @tenant, user: @user, entity: "Product", all: true, ids: "")
    records = build_records({ search: @overhours.product_number }, batch)
    assert_includes records.pluck(:id), @overhours.id
  end
end
