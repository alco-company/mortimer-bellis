require "application_system_test_case"

class EditorTest < ApplicationSystemTestCase
  # setup do
  #   @tenant = tenants(:one)
  #   @user = users(:superadmin)
  #   Current.system_user = @user
  # end

  test "the editor to have a preview pane" do
    output = render Editors::Html::UI.new
    assert_match "<div\ id=\"preview\-pane\"", output
  end
end
