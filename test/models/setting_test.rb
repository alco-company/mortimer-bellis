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
    Setting.create tenant: users(:one).tenant, setable: users(:one), key: "show_all_time_material_posts", value: "true"
    assert users(:one).settings.count == 1
    assert users(:one).can? :show_all_time_material_posts
    refute users(:two).can? :delegate_time_materials
  end

  test "all Users can show all TimeMaterial posts" do
    Setting.create tenant: users(:one).tenant, setable_type: "User", setable_id: nil, key: "show_all_time_material_posts", value: "true"
    assert users(:one).settings.count == 0
    assert users(:one).can? :show_all_time_material_posts
    assert users(:two).cannot? :show_all_time_material_posts
  end

  test "getting time_material settings - general use case " do
    Current.system_user = users(:one)
    settings = Setting.time_material_settings
    assert settings.present?
    assert users(:one).can? :delegate_time_materials
    assert users(:two).cannot? :delegate_time_materials
    assert users(:three).can? :delegate_time_materials
  end

  test "getting time_material settings - all teams use case " do
    Current.system_user = users(:one)
    settings = Setting.time_material_settings(resource: Team)
    assert settings.present?
    assert settings.all? { |s| o = s.second["object"]; o.setable_type == "Team" && o.setable_id == nil }
    assert users(:one).can? :add_time_materials
    Setting.create tenant: users(:two).tenant, setable: users(:two), key: "add_time_materials", value: "false"
    assert users(:two).cannot? :add_time_materials
    assert users(:three).can? :add_time_materials
  end

  test "getting time_material settings - specific team use case " do
    Current.system_user = users(:one)
    settings = Setting.time_material_settings(resource: teams(:one))
    assert settings.present?
    assert settings.all? { |s| o = s.second["object"]; o.setable_type == "Team" && o.setable_id == teams(:one).id  }
    assert users(:one).can? :add_time_materials
    Setting.create tenant: users(:two).tenant, setable: users(:two).team, key: "add_time_materials", value: "false"
    assert users(:two).cannot? :add_time_materials
    assert users(:three).cannot? :add_time_materials
  end

  test "getting time_material settings - all user use case " do
    Current.system_user = users(:one)
    settings = Setting.time_material_settings(resource: User)
    assert settings.present?
    assert settings.all? { |s| o = s.second["object"]; o.setable_type == "User" && o.setable_id == nil  }
    assert users(:one).can? :add_time_materials
    assert users(:two).cannot? :add_time_materials
    assert users(:three).can? :add_time_materials
    Setting.create tenant: users(:two).tenant, setable: users(:two), key: "add_time_materials", value: "false"
    assert users(:two).cannot? :add_time_materials
    set = Setting.create tenant: users(:three).tenant, key: "add_time_materials", value: "false"
    assert set.persisted?
    # user 3 can still add time materials b/c the class level 'true' value
    assert users(:three).can? :add_time_materials
  end

  test "getting time_material settings - specific user use case " do
    Current.system_user = users(:one)
    settings = Setting.time_material_settings(resource: users(:one))
    assert settings.present?
    assert settings.all? { |s| o = s.second["object"]; o.setable_type == "User" && o.setable_id == users(:one).id  }
    assert users(:one).can? :delegate_time_materials
    assert users(:two).cannot? :delegate_time_materials
    assert users(:three).can? :delegate_time_materials
    Setting.create tenant: users(:three).tenant, setable: users(:three).team, key: "delegate_time_materials", value: "false"
    assert users(:three).cannot? :delegate_time_materials
  end
end
