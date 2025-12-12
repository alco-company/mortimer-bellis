class BatchesController < ApplicationController
  attr_reader :resource_class, :notice
  before_action :set_batch, only: %i[ show edit update ]

  def batch_done
    redirect_to url, notice: notice
  end

  def destroy
    Batch.find(params.expect(:id)).destroy
    redirect_to url, notice: "Batch was successfully destroyed."
  end

  protected
    #
    # the tricky part about PATCH /batches/:id is that
    # some url like /customers will update the batch
    # and this is how we fix this
    #
    def method_for_action(action_name)
      super || batch_method
    end

    # should return symbol or string with method to 'run'
    def batch_method
      set_batch
      if batch_method_defined?
        resource_class.new.send(batch_action.to_sym, @batch.entities)
        @batch.delete
      end

      @notice = "Batch action completed."
      :batch_done
    rescue
      @notice = nil # "Batch action failed."
      :batch_done
    end

    def batch_method_defined?
      resource_class.new.public_methods.include? batch_action.to_sym
    end

    def batch_action
      params.dig(:batch, :action)
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_batch
      @batch = Batch.find(params.expect(:id))
      @resource_class = @batch.class # entity.constantize
      @batch&.persist(batch_params)
    end

    def url
      url = params.dig(:url) || params.dig(:batch, :url)
      url.gsub!(/search=.[^&]*/, "")
      url += "?replace=true"
      url.gsub!(/\?\?/, "?")
      url or url_for(controller: resource_class.table_name, action: :index)
    end

    # Only allow a list of trusted parameters through.
    def batch_params
      merge_ids unless params.dig(:batch, :action) == "destroy"
      params.expect(batch: [ :id, :entity, :all, :user_id, ids: [] ])
    end

    def merge_ids
      params[:batch][:ids] = if params.dig(:batch, :all) == "1"
        []
      else
        range = get_ids_range
        ids_old = @batch&.ids.blank? ? [] : @batch&.ids.split(",").collect { |i| i.to_i }.sort
        ids_new = params.dig(:batch, :ids) ? params.dig(:batch, :ids).collect { |i| i.to_i }.sort : []
        params[:batch][:ids] = ids_old.filter { |i| range.include? i }.empty? ? ids_old + ids_new : ids_new
      end
    end

    def get_ids_range
      rg = params.dig(:batch, :ids_range).split("..")
      if rg.count == 2
        (rg.first.to_i..rg.last.to_i).class == Range ? (rg.first.to_i..rg.last.to_i) : 0..10_000_000_000_000
      else
        raise "not a range"
      end
    rescue
      0..10_000_000_000_000
    end
end
