class ProjectsController < MortimerController
  private

    def resource_create
      if resource_params[:hourly_rate].present?
        resource.hourly_rate = resource_params[:hourly_rate].gsub(",", ".")
      end
      resource.save
    end

    def before_update_callback
      params[:project][:hourly_rate] = resource_params[:hourly_rate].gsub(",", ".") if resource_params[:hourly_rate].present?
      true
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(project: [ :name,
        :tenant_id, :customer_id, :description, :start_date, :end_date,
        :state, :budget, :is_billable, :is_separate_invoice, :hourly_rate,
        :priority, :estimated_minutes, :actual_minutes ])
    end
end
