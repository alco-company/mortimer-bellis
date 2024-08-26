class ModalController < BaseController
  before_action :set_vars, only: [ :new, :show, :create, :destroy, :update ]
  skip_before_action :authenticate_user!, only: [ :destroy ]
  skip_before_action :ensure_accounted_user, only: [ :destroy ]

  def new
    # resource
    case resource_class.to_s.underscore
    when "event"; process_event_new
    when "calendar"; process_calendar_new
    when "employee"; process_employee_new
    when "punch_card"; process_punch_card_new
    else; process_other_new
    end
  end

  def show
    case resource_class.to_s.underscore
    when "employee"; process_employee_show
    when "punch"; process_punch_show
    else; head :not_found and return
    end
  end

  # Parameters: {"authenticity_token"=>"[FILTERED]", "modal_form"=>"payroll", "last_payroll_at"=>"2024-04-16", "update_payroll"=>"on", "button"=>""}
  def create
    case resource_class.to_s.underscore
    when "employee"; process_employee_create
    when "punch_card"; process_punch_card_create
    when "event"; process_event_create
    else; process_other_create
    end
  end

  def update
    case resource_class.to_s.underscore
    when "event"; process_event_update
    else; process_other_update
    end
  end

  #
  def destroy
    (authenticate_user! && ensure_accounted_user) || verify_api_key
    params[:all] == "true" ? process_destroy_all : process_destroy
  end

  private

    def set_vars
      @modal_form = params[:modal_form]
      @attachment = params[:attachment]
      resource()
      @step = params[:step]
      @url = params[:url] || resources_url
      @view = params[:view] || "month"
    end

    def resource
      if params[:id].present?
        @resource = resource_class.find(params[:id]) rescue resource_class.new
      else
        @resource = resource_class.new
      end
    end

    def resource_class
      @resource_class ||= params[:resource_class].classify.constantize
    end

    #
    # --------------------------- NEW --------------------------------

    def process_event_new
      case @modal_form
      when "delete"; @step = "accept"
      else
        @date = params[:date] ? Date.parse(params[:date]) : Date.today
        @view = params[:view] || "month"
        case @step
        when "new"
          @calendar = Calendar.find(params[:id])
          @resource = Event.new(account: @calendar.account, calendar: @calendar, event_metum: EventMetum.new)
        when "edit";  @calendar = @resource.calendar
        end
      end
      @step = "accept"
    end

    def process_calendar_new
      @date = params[:date] ? Date.parse(params[:date]) : Date.current
      @event = Calendar.first
      @step = "accept"
    end

    def process_employee_new
      case @modal_form
      when "import"; @step = "preview"
      else; @step = "accept"
      end
    end

    def process_punch_card_new
      case @modal_form
      when "payroll"; @step = "preview"
      else; @step = "accept"
      end
    end

    def process_other_new
      @step = "accept"
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

    def process_punch_show
      # case params[:step]
      # when "view"
      #   render turbo_stream: turbo_stream.replace("modal_container", partial: "modal/punch", local: { resource: @resource })
      # end
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
        Current.account.update send_state_rrule: params[:send_state_at], send_eu_state_rrule: params[:send_eu_state_at]
        send_file(PunchCard.pdf_file(html_content), filename: "employees_state-#{Date.yesterday}.pdf")
      end
    end

    def process_event_create
      @date = params[:date] ? Date.parse(params[:date]) : Date.current
      @view = params[:view] || "month"
      case EventService.new(resource: @resource, params: params).create
      in { ok:    Event   => rc };  redirect_to calendar_url(rc.calendar, date: @date, view: @view) and return # update calendar
      in { ok:    String => msg };        # flash the string
      in { error: String  => msg };       # return event form with error
      end
    end

    def process_other_create
    end

    #
    # --------------------------- UPDATE --------------------------------

    def process_event_update
      @date = params[:date] ? Date.parse(params[:date]) : Date.current
      @view = params[:view] || "month"

      case EventService.new(resource: @resource, params: params).update
      in { ok:    Event   => rc };  redirect_to calendar_url(rc.calendar, date: @date, view: @view) and return
      in { ok:    String => msg };        # flash the string
      in { error: String  => msg };       # return event form with error
      end
    end

    def process_other_update
      raise "ModalController: Update Not Implemented"
    end

    #
    # --------------------------- DESTROY --------------------------------

    def process_destroy_all
      begin
        set_filter resource_class.to_s.underscore.pluralize
        set_resources
        DeleteAllJob.perform_later account: Current.account, resource_class: resource_class.to_s, sql_resources: @resources.to_sql
        @url.gsub!(/\/\d+$/, "") if @url.match?(/\d+$/)
        respond_to do |format|
          format.html { redirect_to @url, status: 303, success: t("delete_all_later") }
          format.json { head :no_content }
        end
      rescue => e
        say "ERROR on destroy: #{e.message}"
        redirect_to resources_url, status: 303, error: t("something_went_wrong")
      end
    end

    def process_destroy
      begin
        if !params[:attachment].blank?
          case params[:attachment]
          when "logo"; @resource.logo.purge
          when "mugshot"; @resource.mugshot.purge
          end
          redirect_back fallback_location: root_path, success: t(".attachment_deleted")
        else
          cb = get_cb_eval_after_destroy(resource)
          r = resource
          if resource.destroy!
            eval(cb) unless cb.nil?
            @url.gsub!(/\/\d+$/, "") if @url.match?(/\d+$/)
            Broadcasters::Resource.new(r).destroy
            respond_to do |format|
              format.turbo_stream { }
              format.html { redirect_to @url, status: 303, success: t(".post") }
              format.json { head :no_content }
            end
          else
            head :no_content
          end
        end
      rescue => e
        say "ERROR on destroy: #{e.message}"
        redirect_to resources_url, status: 303, error: t("something_went_wrong")
      end
    end

    def get_cb_eval_after_destroy(resource)
      case params[:resource_class]
      when "Punch"
        "PunchCard.recalculate employee: Employee.find(#{resource.employee.id}), across_midnight: false, date: '#{resource.punched_at}'"
      else
        nil
      end
    end

    def html_content
      render_to_string "employees/report_state", layout: "pdf", formats: :pdf
    end

    def resources_url(**options)
      @resources_url ||= url_for(controller: resource_class.to_s.underscore.pluralize, action: :index, **options)
    end

    def set_resources
      @resources = any_filters? ? resource_class.filtered(@filter) : resource_class.by_account()
      @resources = any_sorts? ? resource_class.ordered(@resources, params[:s], params[:d]) : @resources.order(created_at: :desc)
    end

    def set_filter(view = params[:controller].split("/").last)
      @filter_form = resource_class.to_s.underscore.pluralize
      @filter = Filter.where(account: Current.account).where(view: view).take || Filter.new
      @filter.filter ||= {}
    end

    def verify_api_key
      @resource.access_token == params[:api_key] || redirect_to(new_user_session_path)
    end

    def any_filters?
      return false if @filter.nil? or params[:controller].split("/").last == "filters"
      !@filter.id.nil?
    end

    def any_sorts?
      params[:s].present?
    end
end


# case params[:modal_form]
# when "payroll"
#   params[:update_payroll] = params[:update_payroll] == "on" ? true : false
#    DatalonPreparationJob.perform_later account: Current.account, last_payroll_at: Date.parse(params[:last_payroll_at]), update_payroll: params[:update_payroll]
# end

# html_filename = Rails.root.join("tmp", "report_state.html")
# pdf_filename = Rails.root.join("tmp", "#{Current.user.id}_report_state.pdf")
# File.open(html_filename, "w") { |f| f.write(html) }
# if BuildPdfJob.new.perform(html: html_filename, pdf: pdf_filename)
#   AccountMailer.with(account: Current.account, tmpfiles: [ pdf_filename.to_s ]).report_state.deliver_later
# end
# EmployeeEuStateJob.perform_later account: Current.account
