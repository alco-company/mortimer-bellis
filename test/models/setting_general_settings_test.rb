require "test_helper"

class SettingGeneralSettingsTest < ActiveSupport::TestCase
  def with_tenant(tenant)
    Current.stub(:get_tenant, tenant) { yield }
  end

  setup do
    @user   = users(:one)
    @tenant = @user.tenant
    @erp_keys = %w[import_customers_only sync_with_erp]
  end

  test "general_settings creates tenant-level defaults for ERP keys" do
    with_tenant(@tenant) do
      # Clean slate for tenant-level defaults
      Setting.unscoped.where(tenant: @tenant, setable_type: nil, setable_id: nil, key: @erp_keys).delete_all

      result = Setting.general_settings(resource: nil)

      @erp_keys.each do |k|
        obj = result[k]["object"]
        assert obj.is_a?(Setting), "Expected Setting for #{k}"
        assert_equal @tenant.id, obj.tenant_id
        assert_nil obj.setable_type
        assert_nil obj.setable_id

        # Defaults: import_customers_only => "1", sync_with_erp => "1"
        assert_equal "1", result[k]["value"], "Expected default '1' for #{k}"
        assert_equal 1, Setting.unscoped.where(tenant: @tenant, setable_type: nil, setable_id: nil, key: k).count,
                     "Expected a single tenant-level row for key=#{k}"
      end
    end
  end

  test "general_settings preserves existing tenant-level values" do
    with_tenant(@tenant) do
      # Seed existing tenant-level value
      rec = Setting.unscoped.find_or_initialize_by(tenant: @tenant, setable_type: nil, setable_id: nil, key: "import_customers_only")
      rec.value = "0"
      rec.save!

      result = Setting.general_settings(resource: nil)

      assert_equal "0", result["import_customers_only"]["value"], "Should keep existing tenant-level value"
      assert_equal 1, Setting.unscoped.where(tenant: @tenant, setable_type: nil, setable_id: nil, key: "import_customers_only").count
    end
  end

  test "general_settings creates user-level rows when resource is a user" do
    with_tenant(@tenant) do
      Setting.unscoped.where(tenant: @tenant, setable_type: "User", setable_id: @user.id, key: @erp_keys).delete_all

      result = Setting.general_settings(resource: @user)

      @erp_keys.each do |k|
        obj = result[k]["object"]
        assert obj.is_a?(Setting), "Expected Setting for #{k}"
        assert_equal "User", obj.setable_type
        assert_equal @user.id, obj.setable_id
        assert_equal @tenant.id, obj.tenant_id
        assert_includes %w[0 1 true false], result[k]["value"] # default is "1" per current code
      end
    end
  end

  test "general_settings creates class-level rows when resource is User class" do
    with_tenant(@tenant) do
      Setting.unscoped.where(tenant: @tenant, setable_type: "User", setable_id: nil, key: @erp_keys).delete_all

      result = Setting.general_settings(resource: User)

      @erp_keys.each do |k|
        obj = result[k]["object"]
        assert obj.is_a?(Setting), "Expected Setting for #{k}"
        assert_equal "User", obj.setable_type
        assert_nil obj.setable_id
        assert_equal @tenant.id, obj.tenant_id
        assert_equal "1", result[k]["value"], "Expected default '1' for #{k}"
      end
    end
  end
end
