module DefaultActions
  extend ActiveSupport::Concern

  included do
    # GET /users or /users.json
    def index
      params.permit![:url] = resources_url
      @pagy, @records = pagy(@resources)

      respond_to do |format|
        format.html { }
        format.turbo_stream { }
        format.pdf { send_file resource_class.pdf_file(html_content), filename: "#{resource_class.name.pluralize.downcase}-#{Date.today}.pdf" }
        format.csv { send_data resource_class.to_csv(@resources), filename: "#{resource_class.name.pluralize.downcase}-#{Date.today}.csv" }
      end

    rescue => e
      UserMailer.error_report(e.to_s, "DefaultActions#index - failed with params: #{params}").deliver_later
      redirect_to root_path, alert: I18n.t("errors.messages.something_went_wrong", error: e.message)
    end

    def lookup
      set_query
      lookup_options = "%s_lookup_options" % params.permit![:div_id]
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            lookup_options,
            partial: "lookup",
            locals: {
              lookup_options: lookup_options,
              resources: @resources,
              div_id: params.permit![:div_id]
            }
          )
        }
      end
    end

    def erp_pull
      SyncErpJob.perform_later tenant: Current.tenant, user: Current.user, resource_class: resource_class
      redirect_to resources_url, success: t(".erp_pull")
    end

    def html_content
      render_to_string layout: "pdf", formats: :pdf
    end

    # GET /users/1 or /users/1.json
    # renders default views/:models/show.html.erb or views/application/show.html.erb
    # which renders a views/:models/form.rb
    # exceptions are fx dashboards/
    #
    def show
    rescue => e
      UserMailer.error_report(e.to_s, "DefaultActions#show - failed with params: #{params}").deliver_later
      redirect_to root_path, alert: I18n.t("errors.messages.something_went_wrong", error: e.message)
    end

    # GET /users/new
    # renders default views/:models/new.html.erb or views/application/new.html.erb
    # which renders a views/:models/form.rb
    # exceptions are fx time_materials/
    #
    def new
      @resource.tenant_id = Current.tenant.id if resource_class.has_attribute? :tenant_id
      @resource.user_id = Current.user.id if resource_class.has_attribute? :user_id

    rescue => e
      UserMailer.error_report(e.to_s, "DefaultActions#new - failed with params: #{params}").deliver_later
      redirect_to root_path, alert: I18n.t("errors.messages.something_went_wrong", error: e.message)
    end

    # GET /users/1/edit
    # renders default views/:models/edit.html.erb or views/application/edit.html.erb
    # which renders a views/:models/form.rb
    # exceptions are fx time_materials/
    #
    def edit
    rescue => e
      UserMailer.error_report(e.to_s, "DefaultActions#edit - failed with params: #{params}").deliver_later
      redirect_to root_path, alert: I18n.t("errors.messages.something_went_wrong", error: e.message)
    end

    # POST /users or /users.json
    # on success removes turbo_frame 'form' and renders application/flash_message
    # on error renders views/:models/_new.html.erb or views/application/_new.html.erb (Turbo)
    #
    def create
      @resource = resource_class.new(resource_params)
      @resource.tenant_id = Current.tenant.id if resource_class.has_attribute? :tenant_id
      @resource.user_id = Current.user.id if resource_class.has_attribute?(:user_id) && !resource_params[:user_id].present?
      before_create_callback @resource
      respond_to do |format|
        if @resource.save
          create_callback @resource
          Broadcasters::Resource.new(@resource, params.permit!).create
          @resource.notify
          flash[:success] = t(".post")
          format.turbo_stream { render turbo_stream: [
            turbo_stream.update("form", ""),
            turbo_stream.replace("flash_container", partial: "application/flash_message")
            # special
          ] }
          format.html { redirect_to resources_url, success: t(".post") }
          format.json { render :show, status: :created, location: @resource }
        else
          flash.now[:warning] = t(".validation_errors")
          format.turbo_stream { render turbo_stream: [ turbo_stream.update("form", partial: "new"), turbo_stream.replace("flash_container", partial: "application/flash_message") ] }
          format.html { render :new, status: :unprocessable_entity, warning: t(".warning") }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end

    rescue => e
      UserMailer.error_report(e.to_s, "DefaultActions#create - failed with params: #{params}").deliver_later
      redirect_to root_path, alert: I18n.t("errors.messages.something_went_wrong", error: e.message)
    end

    # not used ATM
    # def special
    #   turbo_stream.replace("time_material_buttons", partial: "time_materials/buttons", locals: { time_material: TimeMaterial.new }) if params[:played].present?
    # end

    # PATCH/PUT /users/1 or /users/1.json
    def update
      respond_to do |format|
        if @resource.update(resource_params)
          update_callback @resource
          Broadcasters::Resource.new(@resource, params.permit!).replace
          @resource.notify
          flash[:success] = t(".post")
          format.turbo_stream { render turbo_stream: [
            turbo_stream.update("form", ""),
            turbo_stream.action(:full_page_redirect, resources_url),
            turbo_stream.replace("flash_container", partial: "application/flash_message")
          ] }
          format.html { redirect_to resources_url, success: t(".post") }
          format.json { render :show, status: :ok, location: @resource }
        else
          flash[:warning] = t(".validation_errors")
          format.turbo_stream { render turbo_stream: [
            turbo_stream.update("form", partial: "edit"),
            turbo_stream.replace("flash_container", partial: "application/flash_message")
          ] }
          format.html { render :edit, status: :unprocessable_entity, warning: t(".warning") }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end

    rescue => e
      UserMailer.error_report(e.to_s, "DefaultActions#update - failed with params: #{params}").deliver_later
      redirect_to root_path, alert: I18n.t("errors.messages.something_went_wrong", error: e.message)
    end

    # DELETE /users/1 or /users/1.json
    def destroy
      if params[:all].present? && params[:all] == "true"
        DeleteAllJob.perform_now tenant: Current.tenant, resource_class: resource_class.to_s, sql_resources: @resources.to_sql
        Current.tenant.notify msg: "All #{resource_class.name.underscore.pluralize} was deleted in the background"
        respond_to do |format|
          format.html { redirect_to resources_url, success: t("delete_all_later") }
          format.json { head :no_content }
        end
      else
        if params[:attachment]
          case params[:attachment]
          when "logo"; @resource.logo.purge
          when "mugshot"; @resource.mugshot.purge
          end
          redirect_back fallback_location: root_path, success: t(".attachment_deleted")
        else
          cb = destroy_callback @resource
          begin
            ActiveRecord::Base.connected_to(role: :writing) do
              # All code in this block will be connected to the reading role.
              eval(cb) && @resource.notify && Broadcasters::Resource.new(@resource).destroy if @resource.destroy!
            end
          rescue => error
            say error
          end
          respond_to do |format|
            format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@resource)) }
            format.html { redirect_to resources_url, status: 303, success: t(".post") }
            format.json { head :no_content }
          end
        end
      end

    rescue => e
      UserMailer.error_report(e.to_s, "DefaultActions#destroy - failed with params: #{params}").deliver_later
      redirect_to root_path, alert: I18n.t("errors.messages.something_went_wrong", error: e.message)
    end

    #
    # implement on the controller inheriting this concern
    # in order to 'fix' stuff right before the resource gets saved
    #
    def before_create_callback(obj)
    end

    #
    # implement on the controller inheriting this concern
    # in order to not having to extend the create method on this concern
    #
    def create_callback(obj)
    end

    #
    # implement on the controller inheriting this concern
    # in order to not having to extend the update method on this concern
    #
    def update_callback(obj)
    end

    #
    # implement on the controller inheriting this concern
    # in order to not having to extend the update method on this concern
    #
    # this has to return a method that will be called after the destroy!!
    # ie - it cannot call methods on the object istself!
    #
    def destroy_callback(obj)
    end

    private

      def set_query
        @resources = case resource_class.to_s
        when "Project"
          unless params[:customer_id].blank?
            resource_class
              .where("customer_id = ?", params.permit![:customer_id])
              .where(params.permit![:q].blank? ? "1=1" : "name LIKE ?", "%#{params.permit![:q]}%")
              .limit(10)
          else
            resource_class
              .where(params.permit![:q].blank? ? "1=1" : "name LIKE ?", "%#{params.permit![:q]}%")
              .limit(10)
          end
        else
          resource_class
            .where(params.permit![:q].blank? ? "1=1" : "name LIKE ?", "%#{params.permit![:q]}%")
            .limit(10)
        end

        @resources = [ Struct.new("Lookup", :id, :name).new(id: 0, name: I18n.t("no records were found")) ] if @resources.nil? or @resources.empty?
      end
  end
end
