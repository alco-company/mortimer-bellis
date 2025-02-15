module FiltersHelper
  def any_filters?
    return false if @filter.nil? or params.dig(:controller).split("/").last == "filters" or params.dig(:action) == "lookup"
    # !@filter.id.nil?
    @filter.persisted?
  end
end
