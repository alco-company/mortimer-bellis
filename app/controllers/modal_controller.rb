class ModalController < MortimerController
  before_action :set_vars, only: [ :new, :show, :create, :destroy, :update ]
  before_action :set_batch
  before_action :set_filter # , only: %i[ new index destroy ] # new b/c of modal
  before_action :set_resources # , only: %i[ index destroy ]
  before_action :set_resources_stream

  def new
    # resource
    case params[:modal_form]
    when "restore_backup"; process_restore_backup_new
    when "settings"; process_settings_new
    when "new_task"; process_task_new
    else
      @resource = find_resource
      case resource_class.to_s.underscore
      when "calendar"; process_calendar_new
      when "event"; process_event_new
      when "employee"; process_employee_new
      when "punch_card"; process_punch_card_new
      when "tenant"; process_tenant_new
      when "page"; process_help_new
      else; process_other_new
      end
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
    case params[:modal_form]
    when "restore_backup"; process_restore_backup_create
    when "new_task"; process_task_create
    else
      case resource_class.to_s.underscore
      when "employee"; process_employee_create
      when "punch_card"; process_punch_card_create
      when "event"; process_event_create
      when "time_material"; process_time_material_create
      when "tenant"; process_tenant_create
      else; process_other_create
      end
    end
  end

  # Parameters: {
  #   "authenticity_token"=>"[FILTERED]",
  #   "modal_form"=>"export",
  #   "resource_class"=>"TimeMaterial",
  #   "step"=>"setup",
  #   "all"=>"true",
  #   "id"=>"390",
  #   "search"=>"",
  #   "url"=>"https://localhost:3000/modal",
  #   "archive_after"=>"0"
  #   "file_type"=>"csv",
  #   "export_about"=>"on",
  #   "export_quantity"=>"on",
  #   "export_rate"=>"on",
  #   "export_discount"=>"on",
  #   "export_state"=>"on",
  #   "export_is_invoice"=>"on",
  #   "export_is_free"=>"on",
  #   "export_is_offer"=>"on",
  #   "export_is_separate"=>"on",
  #   "export_comment"=>"on",
  #   "export_unit_price"=>"on",
  #   "export_unit"=>"on",
  #   "export_time_spent"=>"on",
  #   "export_over_time"=>"on",
  #   "export_registered_minutes"=>"on",
  #   "export_task_comment"=>"on",
  #   "export_location_comment"=>"on",
  #   "button"=>""
  # }
  def update
    # case resource_class.to_s.underscore
    case params[:modal_form]
    when "export"; process_export
    # when "event"; process_event_update
    else; process_other_update
    end
  end

  #
  def destroy
    params[:action] = "destroy"
    params[:all] == "true" ? process_destroy_all : process_destroy
  end

  private

    def set_vars
      @modal_form = params[:modal_form]
      @attachment = params[:attachment] rescue nil
      @step = params[:step] || "accept" rescue ""
      @url = params[:url] || resources_url rescue root_url
      @view = params[:view] || "month"
      @search = params[:search] || ""
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
          @resource = Event.new(tenant: @calendar.tenant, calendar: @calendar, color: @calendar.calendarable.color, event_metum: EventMetum.new)
        when "edit";  @calendar = @resource.calendar
        end
      end
      @step = "accept"
    end

    def process_settings_new
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

    def process_tenant_new
      @step = "get_pay_link"
    end

    def process_help_new
    end

    def process_task_new
      @modal_form = "new_task"
      @step = params[:modal_next_step] || "accept"
      @url = params.dig(:url) || resources_url rescue root_url
      @resource.due_at = Date.current
      @ids = @filter.filter != {} || @batch&.batch_set? || @search.present? ? resources.pluck(:id) : []
    end

    def process_other_new
      @step = params[:modal_next_step] || "accept"
      @url = params.dig(:url) || resources_url rescue root_url
      @ids = @filter.filter != {} || @batch&.batch_set? || @search.present? ? resources.pluck(:id) : []
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

    #  {"authenticity_token"=>"[FILTERED]", "modal_form"=>"buy_product", "resource_class"=>"Tenant", "step"=>"pick_product", "search"=>"", "tenant"=>{"license"=>"pro"}, "button"=>""}
    def process_tenant_create
      case params[:step]
      when "get_pay_link"
        if params[:tenant][:license] == "1" # "ambassador"
          Current.get_tenant.update license: "ambassador", license_changed_at: Time.current, license_expires_at: Time.current + 1.month
          TenantMailer.with(tenant: Current.get_tenant, user: Current.get_user, recipient: "info@mortimer.pro").send_ambassador_request.deliver_later

          flash[:success] = t("tenant.modal.buy_product.we_got_notified_you_will_hear_from_us_soon")
          render turbo_stream: [
            turbo_stream.replace("new_form_modal", ""),
            turbo_stream.replace("tenant_license", partial: "modal/tenant_license"),
            turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
            # special
          ]
          flash.clear
        else
          license = Tenant.new.licenses(params[:tenant][:license])
          price = params[:tenant][:invoice_yearly] == "1" ? "yr" : "mth"
          url = Stripe::Service.new.payment_link product: license, price: price, url: stripe_payment_new_url(ui: Current.user.id)
          render turbo_stream: turbo_stream.replace("modal_container", partial: "modal/stripe_checkout", locals: { url: url })
        end
      end
    end

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

    def process_task_create
      new_resource params.dig(:task).permit(:title, :description, :tasked_for_id, :due_at, :priority, :customer_id, :project_id)
      resource.tasked_for_type = "User"
      resource.priority ||= 0
      resource.tenant = Current.get_tenant
      if before_create_callback && resource_create && create_callback
        Broadcasters::Resource.new(resource,
          params.permit!,
          stream: "#{Current.get_user.id}_tasks",
          target: "task_list",
          # partial: DashboardTask.new(task: resource, show_options: false, menu: true),
          user: Current.get_user).create
        resource.notify action: :create
        flash.now[:success] = t("tasks.create.post")
        render turbo_stream: [
          turbo_stream.close_remote_modal { },
          turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
          # special
        ]
        flash.clear
      else
        flash.now[:alert] = "FEJL!" # t("tasks.create.post")
        render turbo_stream: [
          # turbo_stream.close_remote_modal { },
          turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
          # special
        ]
        flash.clear
      end
    end

    def process_time_material_create
      ids = @filter.filter != {} || @batch&.batch_set? || @search.present? ? resources.pluck(:id) : nil
      DineroUploadJob.perform_later(tenant: Current.tenant, user: Current.user, date: Date.current, provided_service: "Dinero", ids: ids)
      flash.now[:success] = t("time_material.uploading_to_erp")
      render turbo_stream: [
        turbo_stream.close_remote_modal { },
        turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
      ]
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

    def process_export
      selected_fields = params.select { |k, v| k.start_with?("export_") && v == "on" }.keys.map { |k| k.gsub("export_", "") }
      case params[:file_type]
      when "pdf"; send_pdf
      when "csv"; send_data resource_class.to_csv(@resources, selected_fields), filename: "#{resource_class.name.pluralize.downcase}-#{Date.today}.csv"
      end
    end

    def process_other_update
      raise "ModalController: Update Not Implemented"
    end

    #
    # --------------------------- DESTROY --------------------------------

    def process_destroy_all
      begin
        if resource_class == Setting && params[:reason] != t("setting.modal.delete.reason_typed")
          flash[:error] = t("setting.modal.delete.reason_required")
          respond_to do |format|
            format.turbo_stream { }
            format.html { redirect_to resources_url, status: 303, error: t("setting.modal.delete.reason_required") }
            format.json { head :no_content }
          end
        else
          DeleteAllJob.perform_now tenant: Current.tenant, user: Current.user, resource_class: resource_class.to_s,
            ids: resources.pluck(:id),
            batch: @batch,
            user_ids: (resource_class.first.respond_to?(:user_id) ? resources.pluck(:user_id).uniq : User.by_tenant.by_role(:user).pluck(:id)) rescue nil
          @url.gsub!(/\/\d+$/, "") if @url.match?(/\d+$/)
          flash[:success] = t("delete_all_later")
          respond_to do |format|
            format.turbo_stream { }
            format.html { redirect_to @url, status: 303, success: t("delete_all_later") }
            format.json { head :no_content }
          end
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
          render turbo_stream: [
            turbo_stream.close_remote_modal { },
            turbo_stream.replace("attachment", "")
          ]
          # redirect_back fallback_location: root_path, success: t(".attachment_deleted")
        else
          cb = get_cb_eval_after_destroy(resource)
          r = resource_class.build resource.attributes
          if resource.remove params[:step]
            eval(cb) unless cb.nil?
            @url.gsub!(/\/\d+$/, "") if @url.match?(/\d+$/)
            resource_class == TimeMaterial ? time_material_stream_destroy : Broadcasters::Resource.new(r).destroy
            r.notify(action: :destroy)
            r.destroy!
            flash[:success] = t(".post")
            params[:step] == "delete_account" ? redirect_to(root_path) : do_respond
          else
            head :no_content
          end
        end
      rescue => e
        say "ERROR on destroy: #{e.message}"
        redirect_to show_dashboard_dashboards_url, status: 303, error: t("something_went_wrong", error: e.message)
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

    def time_material_stream_destroy
      Broadcasters::Resource.new(resource, user: Current.user, stream: "#{Current.user.id}_time_materials").destroy
      Current.get_tenant.users.each do |u|
        next unless u.current_sign_in_at.present? && u != Current.user
        Broadcasters::Resource.new(resource, user: u, stream: "#{u.id}_time_materials").destroy
      end
    end

    def process_restore_backup_new
      @filename = params[:filename]
      @backup_date = DateTime.parse(@filename.split("_")[2].split(".")[0]).in_time_zone rescue Time.current
    end

    def process_restore_backup_create
      # This shouldn't be called anymore since the form submits directly to tenant_backups#restore
      # But keeping it for backwards compatibility
      filename = params[:filename]
      redirect_to root_path, alert: "Please use the modal to confirm restore."
    end

  # def any_filters?
  #   return false if @filter.nil? or params.dig(:controller).split("/").last == "filters" or params.dig(:action) == "lookup"
  #   # !@filter.id.nil?r
  #   @filter.persisted?
  # end

  # def any_sorts?
  #   params.dig :s
  # end
end
