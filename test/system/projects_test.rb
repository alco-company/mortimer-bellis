require "application_system_test_case"

class ProjectsTest < ApplicationSystemTestCase
  setup do
    @project = projects(:one)
  end

  test "visiting the index" do
    visit projects_url
    assert_selector "h1", text: "Projects"
  end

  test "should create project" do
    visit projects_url
    click_on "New project"

    fill_in "Actual minutes", with: @project.actual_minutes
    fill_in "Budget", with: @project.budget
    fill_in "Customer", with: @project.customer_id
    fill_in "Description", with: @project.description
    fill_in "End date", with: @project.end_date
    fill_in "Estimated minutes", with: @project.estimated_minutes
    fill_in "Hourly rate", with: @project.hourly_rate
    check "Is billable" if @project.is_billable
    fill_in "Name", with: @project.name
    fill_in "Priority", with: @project.priority
    fill_in "Start date", with: @project.start_date
    fill_in "State", with: @project.state
    fill_in "Tenant", with: @project.tenant_id
    click_on "Create Project"

    assert_text "Project was successfully created"
    click_on "Back"
  end

  test "should update Project" do
    visit project_url(@project)
    click_on "Edit this project", match: :first

    fill_in "Actual minutes", with: @project.actual_minutes
    fill_in "Budget", with: @project.budget
    fill_in "Customer", with: @project.customer_id
    fill_in "Description", with: @project.description
    fill_in "End date", with: @project.end_date.to_s
    fill_in "Estimated minutes", with: @project.estimated_minutes
    fill_in "Hourly rate", with: @project.hourly_rate
    check "Is billable" if @project.is_billable
    fill_in "Name", with: @project.name
    fill_in "Priority", with: @project.priority
    fill_in "Start date", with: @project.start_date.to_s
    fill_in "State", with: @project.state
    fill_in "Tenant", with: @project.tenant_id
    click_on "Update Project"

    assert_text "Project was successfully updated"
    click_on "Back"
  end

  test "should destroy Project" do
    visit project_url(@project)
    click_on "Destroy this project", match: :first

    assert_text "Project was successfully destroyed"
  end
end
