require "application_system_test_case"

class ModalTest < ApplicationSystemTestCase
  setup do
    @tenant = tenants(:one)
    @user = users(:superadmin)
  end

  test "visiting the index" do
    login_as(@user)
    visit root_url
    assert_match "remote-modal-container", page.html
  end
end
