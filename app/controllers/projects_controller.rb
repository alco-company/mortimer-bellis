class ProjectsController < MortimerController
  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(project: [ :name,
        :tenant_id, :customer_id, :description, :start_date, :end_date,
        :state, :budget, :is_billable, :is_separate_invoice, :hourly_rate,
        :priority, :estimated_minutes, :actual_minutes ])
    end
end
