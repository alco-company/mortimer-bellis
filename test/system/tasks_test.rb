require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  setup do
    @task = tasks(:one)
  end

  test "visiting the index" do
    visit tasks_url
    assert_selector "h1", text: "Tasks"
  end

  test "should create task" do
    visit tasks_url
    click_on "New task"

    fill_in "Ancestry", with: @task.ancestry
    check "Archived" if @task.archived
    fill_in "Completed at", with: @task.completed_at
    fill_in "Description", with: @task.description
    fill_in "Due at", with: @task.due_at
    fill_in "Location", with: @task.location_id
    fill_in "Priority", with: @task.priority
    fill_in "Progress", with: @task.progress
    fill_in "Project", with: @task.project_id
    fill_in "State", with: @task.state
    fill_in "Tenant", with: @task.tenant_id
    fill_in "Title", with: @task.title
    click_on "Create Task"

    assert_text "Task was successfully created"
    click_on "Back"
  end

  test "should update Task" do
    visit task_url(@task)
    click_on "Edit this task", match: :first

    fill_in "Ancestry", with: @task.ancestry
    check "Archived" if @task.archived
    fill_in "Completed at", with: @task.completed_at.to_s
    fill_in "Description", with: @task.description
    fill_in "Due at", with: @task.due_at.to_s
    fill_in "Location", with: @task.location_id
    fill_in "Priority", with: @task.priority
    fill_in "Progress", with: @task.progress
    fill_in "Project", with: @task.project_id
    fill_in "State", with: @task.state
    fill_in "Tenant", with: @task.tenant_id
    fill_in "Title", with: @task.title
    click_on "Update Task"

    assert_text "Task was successfully updated"
    click_on "Back"
  end

  test "should destroy Task" do
    visit task_url(@task)
    click_on "Destroy this task", match: :first

    assert_text "Task was successfully destroyed"
  end
end
