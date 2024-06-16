require "application_system_test_case"

class BackgroundJobsTest < ApplicationSystemTestCase
  setup do
    @background_job = background_jobs(:one)
  end

  # test "visiting the index" do
  #   visit background_jobs_url
  #   assert_selector "h1", text: "Background jobs"
  # end

  # test "should create background job" do
  #   visit background_jobs_url
  #   click_on "New background job"

  #   fill_in "Account", with: @background_job.account_id
  #   fill_in "Job", with: @background_job.job_id
  #   fill_in "Job klass", with: @background_job.job_klass
  #   fill_in "Next run at", with: @background_job.next_run_at
  #   fill_in "Params", with: @background_job.params
  #   fill_in "Schedule", with: @background_job.schedule
  #   fill_in "State", with: @background_job.state
  #   fill_in "User", with: @background_job.user_id
  #   click_on "Create Background job"

  #   assert_text "Background job was successfully created"
  #   click_on "Back"
  # end

  # test "should update Background job" do
  #   visit background_job_url(@background_job)
  #   click_on "Edit this background job", match: :first

  #   fill_in "Account", with: @background_job.account_id
  #   fill_in "Job", with: @background_job.job_id
  #   fill_in "Job klass", with: @background_job.job_klass
  #   fill_in "Next run at", with: @background_job.next_run_at.to_s
  #   fill_in "Params", with: @background_job.params
  #   fill_in "Schedule", with: @background_job.schedule
  #   fill_in "State", with: @background_job.state
  #   fill_in "User", with: @background_job.user_id
  #   click_on "Update Background job"

  #   assert_text "Background job was successfully updated"
  #   click_on "Back"
  # end

  # test "should destroy Background job" do
  #   visit background_job_url(@background_job)
  #   click_on "Destroy this background job", match: :first

  #   assert_text "Background job was successfully destroyed"
  # end
end
