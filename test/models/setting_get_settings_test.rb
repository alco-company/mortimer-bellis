require "test_helper"

class SettingGetSettingsTest < ActiveSupport::TestCase
  def with_tenant(tenant, &block)
    Current.stub(:get_tenant, tenant) do
      yield
    end
  end

  setup do
    @user  = users(:one)
    @team  = teams(:one)   if defined?(teams)
    @tm    = time_materials(:one) if defined?(time_materials)
    @tenant = @user.tenant
  end

  test "tenant-level time_material_settings (resource: nil) creates defaults once and returns objects" do
    with_tenant(@tenant) do
      # First call creates tenant-level defaults (setable_type/id nil)
      result1 = Setting.time_material_settings(resource: nil)
      # Second call should not create duplicates
      result2 = Setting.time_material_settings(resource: nil)

      keys = Setting::DEFAULT_TIME_SETTINGS.keys

      assert keys.all? { |k| result1[k].is_a?(Hash) && result1[k]["object"].is_a?(Setting) }
      assert_equal keys.sort, result1.keys.sort
      assert_equal keys.sort, result2.keys.sort

      # Ensure uniqueness per-key at tenant-level
      keys.each do |k|
        rel = Setting.unscoped.where(tenant: @tenant, setable_type: nil, setable_id: nil, key: k)
        assert_equal 1, rel.count, "Expected only 1 tenant-level row for key=#{k}"
      end
    end
  end

  test "class-level defaults for User (resource: User) are created with setable_type User and id nil" do
    with_tenant(@tenant) do
      result = Setting.user_settings(resource: User)

      Setting::DEFAULT_TIME_SETTINGS.keys.each do |k|
        obj = result[k]["object"]
        assert obj.is_a?(Setting), "Expected Setting object for key=#{k}"
        assert_equal "User", obj.setable_type
        assert_nil obj.setable_id
        assert_equal @tenant.id, obj.tenant_id
      end
    end
  end

  test "class-level defaults for Team (resource: Team) are created with setable_type Team and id nil" do
    skip "No teams fixture present" unless @team
    with_tenant(@tenant) do
      result = Setting.team_settings(resource: Team)

      Setting::DEFAULT_TIME_SETTINGS.keys.each do |k|
        obj = result[k]["object"]
        assert obj.is_a?(Setting), "Expected Setting object for key=#{k}"
        assert_equal "Team", obj.setable_type
        assert_nil obj.setable_id
        assert_equal @tenant.id, obj.tenant_id
      end
    end
  end

  test "instance-level defaults for specific User (resource: user) are created with setable_type User and id=user.id" do
    with_tenant(@tenant) do
      result = Setting.user_settings(resource: @user)

      Setting::DEFAULT_TIME_SETTINGS.keys.each do |k|
        obj = result[k]["object"]
        assert obj.is_a?(Setting), "Expected Setting object for key=#{k}"
        assert_equal "User", obj.setable_type
        assert_equal @user.id, obj.setable_id
        assert_equal @tenant.id, obj.tenant_id
      end
    end
  end

  test "instance-level defaults for specific Team (resource: team) are created with setable_type Team and id=team.id" do
    skip "No teams fixture present" unless @team
    with_tenant(@tenant) do
      result = Setting.team_settings(resource: @team)

      Setting::DEFAULT_TIME_SETTINGS.keys.each do |k|
        obj = result[k]["object"]
        assert obj.is_a?(Setting), "Expected Setting object for key=#{k}"
        assert_equal "Team", obj.setable_type
        assert_equal @team.id, obj.setable_id
        assert_equal @tenant.id, obj.tenant_id
      end
    end
  end

  test "existing instance-level user setting value is preserved by get_settings" do
    with_tenant(@tenant) do
      key = "add_time_materials"
      # Create an explicit user-level setting first
      rec = Setting.create!(
        tenant: @tenant,
        setable_type: "User",
        setable_id: @user.id,
        key: key,
        value: "false"
      )
      result = Setting.user_settings(resource: @user)

      assert_equal "false", result[key]["value"]
      assert_equal rec.id,  result[key]["id"]
      assert_equal rec,     result[key]["object"]
    end
  end

  test "user-level creation ignores tenant-level value when creating a new user-level row" do
    with_tenant(@tenant) do
      key = "add_time_materials"
      # Tenant-level default set to false
      Setting.unscoped.find_or_create_by!(
        tenant: @tenant, setable_type: nil, setable_id: nil, key: key, value: "false"
      ).update!(value: "false")

      # No existing user-level record; user_settings should create a new row with the default from DEFAULT_TIME_SETTINGS ("true")
      result = Setting.user_settings(resource: @user)
      assert_equal "true", result[key]["value"], "Expected new user-level default to come from DEFAULT_TIME_SETTINGS, not tenant-level"
      obj = result[key]["object"]
      assert_equal "User", obj.setable_type
      assert_equal @user.id, obj.setable_id
    end
  end

  test "uniqueness per tenant+target+key is enforced" do
    with_tenant(@tenant) do
      key = "delegate_time_materials"
      Setting.create!(tenant: @tenant, setable_type: "User", setable_id: @user.id, key: key, value: "true")

      dup = Setting.new(tenant: @tenant, setable_type: "User", setable_id: @user.id, key: key, value: "false")
      refute dup.valid?
      assert_includes dup.errors.attribute_names, :key
    end
  end

  test "time_material_settings for class TimeMaterial create class-level rows" do
    with_tenant(@tenant) do
      result = Setting.time_material_settings(resource: TimeMaterial)

      Setting::DEFAULT_TIME_SETTINGS.keys.each do |k|
        obj = result[k]["object"]
        assert_equal "TimeMaterial", obj.setable_type
        assert_nil obj.setable_id
      end
    end
  end

  test "time_material_settings for instance TimeMaterial create instance-level rows" do
    skip "No time_materials fixture present" unless @tm
    with_tenant(@tenant) do
      result = Setting.time_material_settings(resource: @tm)

      Setting::DEFAULT_TIME_SETTINGS.keys.each do |k|
        obj = result[k]["object"]
        assert_equal "TimeMaterial", obj.setable_type
        assert_equal @tm.id, obj.setable_id
      end
    end
  end
end
