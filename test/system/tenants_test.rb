require "application_system_test_case"

class TenantsTest < ApplicationSystemTestCase
  setup do
    @tenant = tenants(:one)
    user = users(:superadmin)
    sign_in user
  end

  test "visiting the index" do
    visit tenants_url
    assert_selector "h1", text: "Konti"
  end

  test "should create tenant" do
    visit tenants_url
    click_on "Ny konto"

    fill_in "tenant_name", with: "nyt firma"
    fill_in "tenant_email", with: @tenant.email
    select "Grå", from: "tenant_color"
    select "Dansk", from: "tenant_locale"
    fill_in "tenant_pp_identification", with: @tenant.pp_identification
    select "Europe/Copenhagen - (GMT+01:00) Copenhagen", from: "tenant_time_zone"
    click_on "Opret"

    assert_text "Kontoen blev oprettet"
  end

  test "should update Tenant" do
    visit edit_tenant_url(@tenant)

    fill_in "tenant_name", with: @tenant.name
    fill_in "tenant_email", with: @tenant.email
    select "Grå", from: "tenant_color"
    select "Dansk", from: "tenant_locale"
    fill_in "tenant_pp_identification", with: @tenant.pp_identification
    select "Europe/Copenhagen - (GMT+01:00) Copenhagen", from: "tenant_time_zone"
    click_on "Opdatér"

    assert_text "Kontoen blev opdateret"
  end

  test "should not destroy own Tenant" do
    visit tenants_url()
    tenant_li = find("li", text: @tenant.name)
    within(tenant_li) do
      click_on "Open item options", match: :first
      assert_link "Slet", count: 0
    end
  end

  test "should destroy Tenant" do
    visit tenants_url
    tenant_name = tenants(:two).name
    tenant_li = find("li", text: tenant_name)
    within(tenant_li) do
      click_on "Open item options", match: :first
      click_on "Slet"
    end
    within("dialog#new_form_modal") do
      assert_text "Slet denne konto"
      click_on "Slet"
    end

    assert_text "Posten blev slettet korrekt"
  end
end
