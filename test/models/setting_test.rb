require "test_helper"

class SettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  # t.string "setable_type"
  # t.integer "setable_id"
  # t.string "key"
  # t.integer "priority"
  # t.string "format"
  # t.string "value"
  test "should not save setting without proper values" do
    setting = Setting.new tenant: Tenant.first, key: "test", value: "test"
    assert setting.valid?
  end

  test "control access to all time_material posts" do
    Setting.create tenant: Tenant.first, setable: User.first, key: "show_all_time_material_posts", value: "true"
    assert User.first.settings.count == 1
    assert User.first.can? :show_all_time_material_posts
    assert_not User.second.can? :show_all_time_material_posts
  end

  test "all Users can show all TimeMaterial posts" do
    Setting.create tenant: Tenant.first, setable_type: "User", key: "show_all_time_material_posts", value: "true"
    assert User.first.settings.count == 0
    assert User.first.can? :show_all_time_material_posts
    assert User.second.can? :show_all_time_material_posts
  end
end
