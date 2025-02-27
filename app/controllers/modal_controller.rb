class ModalController < MortimerController
  before_action :set_vars, only: [ :new, :show, :create, :destroy, :update ]
  skip_before_action :require_authentication, only: [ :destroy ]
  skip_before_action :check_session_length, only: [ :destroy ]

  def new
    # resource
    @resource = find_resource
    case resource_class.to_s.underscore
    when "calendar"; process_calendar_new
    when "event"; process_event_new
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
    when "time_material"; process_time_material_create
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
    params[:action] = "destroy"
    (require_authentication && check_session_length) || verify_api_key
    @resource = find_resource
    params[:all] == "true" ? process_destroy_all : process_destroy
  end

  private

    def set_vars
      @modal_form = params[:modal_form]
      @attachment = params[:attachment]
      set_filter_and_batch
      resource()
      set_resources()
      @step = params[:step]
      @url = params[:url] || resources_url
      @view = params[:view] || "month"
      @search = params[:search]
    end

    def set_filter_and_batch
      @filter_form = resource_class.to_s.underscore.pluralize
      @filter = Filter.by_user.by_view(@filter_form).take || Filter.new
      @filter.filter ||= {}

      @batch = Batch.where(tenant: Current.tenant, user: Current.user, entity: resource_class.to_s).take ||
                Batch.create(tenant: Current.tenant, user: Current.user, entity: resource_class.to_s, ids: "", all: true)
    end

    # def resource
    #   if params[:id].present?
    #     @resource = resource_class.find(params[:id]) rescue resource_class.new
    #   else
    #     @resource = resource_class.new
    #   end
    # end

    # def resource_class
    #   @resource_class ||= case params[:resource_class]
    #   # when "invitations"; UserInvitation
    #   when "notifications"; Noticed::Notification
    #   when "doorkeeper/application"; Oauth::Application
    #   else; params[:resource_class].classify.constantize rescue nil
    #   end
    # end

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
          @resource = Event.new(tenant: @calendar.tenant, calendar: @calendar, color: @calendar.calendarable.color, event_metum: EventMetum.new)
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
      @step = params[:modal_next_step] || "accept"
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
          ImportUsersJob.new.perform(tenant: Current.tenant, import_file: params[:import_file]) :
          ImportUsersJob.perform_later(tenant: Current.tenant, import_file: params[:import_file])

        render turbo_stream: turbo_stream.replace("modal_container", partial: "modal/import_approved")
      end
    end

    def process_punch_card_create
      case params[:modal_form]
      when "payroll"
        params[:update_payroll] = params[:update_payroll] == "on" ? true : false
        DatalonPreparationJob.perform_later tenant: Current.tenant, last_payroll_at: Date.parse(params[:last_payroll_at]), update_payroll: params[:update_payroll]
      when "state"
        Current.tenant.update send_state_rrule: params[:send_state_at], send_eu_state_rrule: params[:send_eu_state_at]
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

    def process_time_material_create
      ids = @filter.filter != {} || @batch&.batch_set? || @search.present? ? @resources.pluck(:id) : nil
      DineroUploadJob.perform_later tenant: Current.tenant, user: Current.user, date: Date.current, provided_service: "Dinero", ids: ids
      flash.now[:success] = t("time_material.uploading_to_erp")
      render turbo_stream: [
        turbo_stream.close_remote_modal { },
        turbo_stream.replace("flash_container", partial: "application/flash_message")
      ]
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
        DeleteAllJob.perform_later tenant: Current.tenant, resource_class: resource_class.to_s,
          ids: @resources.pluck(:id),
          user_ids: (resource_class.first.respond_to?(:user_id) ? @resources.pluck(:user_id).uniq : User.by_tenant.by_role(:user).pluck(:id)) rescue nil
        @url.gsub!(/\/\d+$/, "") if @url.match?(/\d+$/)
        flash[:success] = t("delete_all_later")
        respond_to do |format|
          format.turbo_stream { }
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
          r = resource_class.build resource.attributes
          if resource.remove params[:step]
            eval(cb) unless cb.nil?
            @url.gsub!(/\/\d+$/, "") if @url.match?(/\d+$/)
            Broadcasters::Resource.new(r).destroy
            r.notify(action: :destroy)
            r.destroy
            flash[:success] = t(".post")
            params[:step] == "delete_account" ? redirect_to(root_path) : do_respond
          else
            head :no_content
          end
        end
      rescue => e
        say "ERROR on destroy: #{e.message}"
        redirect_to resources_url, status: 303, error: t("something_went_wrong", error: e.message)
      end
    end

    def do_respond
      respond_to do |format|
        format.turbo_stream { }
        format.html { redirect_to @url, status: 303, success: t(".post") }
        format.json { head :no_content }
      end
    end

    def get_cb_eval_after_destroy(resource)
      case params[:resource_class]
      when "Punch"
        "PunchCard.recalculate user: User.find(#{resource.user.id}), across_midnight: false, date: '#{resource.punched_at}'"
      else
        nil
      end
    end

    def html_content
      render_to_string "employees/report_state", layout: "pdf", formats: :pdf
    end

    def set_resource_class
      @resource_class = params.dig(:resource_class).classify.constantize
    rescue => e
      redirect_to "/", alert: I18n.t("errors.resources.resource_class.not_found", ctrl: params.dig(:resource_class), reason: e.to_s) and return
    end

    def verify_api_key
      return false unless params.dig(:api_key) && @resource && @resource.respond_to?(:access_token)
      @resource.access_token == params.dig(:api_key) || redirect_to(new_users_session_path)
    end

    def any_filters?
      return false if @filter.nil? or params.dig(:controller).split("/").last == "filters" or params.dig(:action) == "lookup"
      # !@filter.id.nil?
      @filter.persisted?
    end

    def any_sorts?
      params.dig :s
    end
end
