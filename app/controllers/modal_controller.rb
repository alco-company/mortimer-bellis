class ModalController < BaseController
  before_action :set_vars, only: [ :new, :show, :create ]

  def new
    case @resource_class
    when "employee"; process_employee_new
    when "punch_card"; process_punch_card_new
    else; head :not_found and return
    end
  end

  def show
    case @resource_class
    when "employee"; process_employee_show
    else; head :not_found and return
    end
  end

  # Parameters: {"authenticity_token"=>"[FILTERED]", "modal_form"=>"payroll", "last_payroll_at"=>"2024-04-16", "update_payroll"=>"on", "button"=>""}
  def create
    case @resource_class
    when "employee"; process_employee_create
    when "punch_card"; process_punch_card_create
    end
  end

  private

    def set_vars
      @modal_form = params[:modal_form]
      @resource_class = params[:resource_class]
      @step = params[:step]
    end

    #
    # --------------------------- NEW --------------------------------
    def process_employee_new
      case @modal_form
      when "import"
        @step = "preview"
      end
    end

    def process_punch_card_new
      case @modal_form
      when "payroll"
        @step = "preview"
      end
    end

    #
    # --------------------------- SHOW --------------------------------
    def process_employee_show
      case params[:step]
      when "template"
        send_file Rails.root.join("public", "templates", "employees.csv"), type: "text/csv", filename: "employees.csv"
      when "dataset"
        # render :import_preview, locals: { model_form: params[:modal_form], step: "approve", resource_class: params[:resource_class], records: @records }
        render turbo_stream: turbo_stream.replace("modal_container", partial: "modal/import_preview", local: { records: @records })
      end
    end


    #
    # --------------------------- CREATE --------------------------------
    def process_employee_create
      case params[:step]
      when "preview"
        require "csv"

        @import_file = Rails.root.join("tmp/storage", DateTime.current.strftime("%Y%m%d%H%M%S"))
        File.open(@import_file, "wb") { |f| f.write(params[:import_file].read) }
        @records = CSV.parse(File.read(@import_file), headers: true, col_sep: ";")
        @step = "approve"
        render turbo_stream: turbo_stream.replace("modal_container", partial: "modal/import_preview", local: { records: @records, import_file: @import_file })
      when "approve"
        Rails.env.local? ?
          ImportEmployeesJob.new.perform(account: Current.account, import_file: params[:import_file]) :
          ImportEmployeesJob.perform_later(account: Current.account, import_file: params[:import_file])

        render turbo_stream: turbo_stream.replace("modal_container", partial: "modal/import_approved")
      end
    end

    def process_punch_card_create
      case params[:modal_form]
      when "payroll"
        params[:update_payroll] = params[:update_payroll] == "on" ? true : false
        DatalonPreparationJob.perform_later account: Current.account, last_payroll_at: Date.parse(params[:last_payroll_at]), update_payroll: params[:update_payroll]
      when "state"
        # params[:send_state_at]
        # params[:send_eu_state_at]
        html = render_to_string "employee_mailer/report_state"
        html_filename = Rails.root.join("tmp", "report_state.html")
        pdf_filename = Rails.root.join("tmp", "#{Current.user.id}_report_state.pdf")
        File.open(html_filename, "wb") { |f| f.write(html) }
        if BuildPdfJob.new.perform(html: html_filename, pdf: pdf_filename)
          AccountMailer.with(account: Current.account, tmpfiles: [ pdf_filename.to_s ]).report_state.deliver_later
        end
        # EmployeeEuStateJob.perform_later account: Current.account
      end
    end
end


# case params[:modal_form]
# when "payroll"
#   params[:update_payroll] = params[:update_payroll] == "on" ? true : false
#    DatalonPreparationJob.perform_later account: Current.account, last_payroll_at: Date.parse(params[:last_payroll_at]), update_payroll: params[:update_payroll]
# end
