class ModalController < ApplicationController

  skip_before_action :ensure_authenticated_user, only: [:show]

  def show 
    case params[:resource_class]
    when 'employee'; send_file Rails.root.join("public","templates","employees.csv"), type: "text/csv", filename: "employees.csv"
    end
  end

  def new
    @modal_form = params[:modal_form]
    @resource_class = params[:resource_class]
  end

  # Parameters: {"authenticity_token"=>"[FILTERED]", "modal_form"=>"payroll", "last_payroll_at"=>"2024-04-16", "update_payroll"=>"on", "button"=>""}
  def create
    case params[:modal_form]
    when 'payroll'
      params[:update_payroll] = params[:update_payroll] == 'on' ? true : false
       DatalonPreparationJob.perform_later account: Current.account, last_payroll_at: Date.parse(params[:last_payroll_at]), update_payroll: params[:update_payroll]
    end
  end
end
