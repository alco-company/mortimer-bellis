class Pos::PosController < ApplicationController

  before_action :verify_token
  before_action :verify_employee

  layout -> { PosPunchClockLayout }

  private 

    def verify_employee
      @employee = case true 
      when params[:employee_id].present?; Employee.find(params.delete(:employee_id))
      when params[:employee].present?; Employee.find(params[:employee][:id])
      when params[:q].present?; Employee.find_by( pincode: params[:q])
      else nil
      end
      redirect_to pos_punch_clock_path(api_key: @resource.access_token) and return unless @employee
    end

    def verify_token
      api_key = case true 
      when params[:api_key].present?; params.delete(:api_key)
      when params[:punch_card].present?; params[:punch_card].delete(:api_key)
      when params[:punch_clock].present?; params[:punch_clock].delete(:api_key)
      else ''
      end
      @resource = PunchClock.find_by( access_token: api_key)
      redirect_to root_path and return if @resource.nil?
      # @resource.regenerate_access_token
    end

end