class TimeMaterialStatsController < MortimerController
  def index
    @range_view = params[:range_view] || "week"
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("#{Current.get_user.id}_time_material_stats", partial: "dashboards/time_material_stats", locals: { range_view: @range_view })
        ]
      end
    end
  end
end
