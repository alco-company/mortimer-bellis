class AddJobProgressToBackgroundJobs < ActiveRecord::Migration[8.1]
  def change
    add_column :background_jobs, :job_progress, :text
  end
end
