class BatchesController < ApplicationController
  attr_reader :resource_class

  def batch_done
    redirect_to url_for(controller: resource_class.to_s.tableize, action: :index), notice: "Batch action completed."
  end

  protected
    def method_for_action(action_name)
      super || if batch_method_defined?
                  resource_class.new.send(batch_action.to_sym, @batch.entities)
                  @batch.delete
                  :batch_done
               end
    end

    def batch_method_defined?
      set_batch
      resource_class.new.public_methods.include? batch_action.to_sym
    end

    def batch_action
      params.dig(:batch, :action)
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_batch
      @batch = Batch.find(params.expect(:id))
      @resource_class = @batch.entity.constantize
      @batch&.update(batch_params)
    end

    # Only allow a list of trusted parameters through.
    def batch_params
      merge_ids
      params.expect(batch: [ :id, :entity, :all, :user_id, :ids ])
    end

    def merge_ids
      params[:batch][:ids] = if params.dig(:batch, :all) == "1"
        ""
      else
        range = eval params.dig(:batch, :ids_range)
        ids_old = @batch&.ids.blank? ? [] : @batch&.ids.split(",").collect { |i| i.to_i }.sort
        ids_new = params.dig(:batch, :ids).collect { |i| i.to_i }.sort
        params[:batch][:ids] = ids_old.filter { |i| range.include? i }.empty? ? ids_old + ids_new : ids_new
      end
    end
end
