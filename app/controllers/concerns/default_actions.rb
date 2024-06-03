module DefaultActions
  extend ActiveSupport::Concern

  included do
    before_action :set_resource, only: %i[ new show edit update destroy ]
    before_action :set_filter, only: %i[ index destroy ]
    before_action :set_resources, only: %i[ index destroy ]

    # GET /employees or /employees.json
    def index
      params[:url] = resources_url
      @pagy, @records = pagy(@resources)

      respond_to do |format|
        format.html { }
        format.pdf { send_file resource_class.pdf_file(html_content), filename: "#{resource_class.name.pluralize.downcase}-#{Date.today}.pdf" }
        format.csv { send_data resource_class.to_csv(@resources), filename: "#{resource_class.name.pluralize.downcase}-#{Date.today}.csv" }
      end
    rescue => error
      redirect_to root_path, warning: error.message
    end

    def html_content
      render_to_string layout: "pdf", formats: :pdf
    end

    # GET /employees/1 or /employees/1.json
    def show
    end

    # GET /employees/new
    def new
      @resource.account_id = Current.account.id if resource_class.has_attribute? :account_id
      @resource.user_id = Current.user.id if resource_class.has_attribute? :user_id
    end

    # GET /employees/1/edit
    def edit
    end

    # POST /employees or /employees.json
    def create
      @resource = resource_class.new(resource_params)
      @resource.account_id = Current.account.id if resource_class.has_attribute? :account_id
      @resource.user_id = Current.user.id if resource_class.has_attribute? :user_id

      respond_to do |format|
        if @resource.save
          create_callback @resource
          format.html { redirect_to resources_url, success: t(".post") }
          format.json { render :show, status: :created, location: @resource }
        else
          format.html { render :new, status: :unprocessable_entity, warning: t(".warning") }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /employees/1 or /employees/1.json
    def update
      respond_to do |format|
        if @resource.update(resource_params)
          update_callback @resource
          format.html { redirect_to resources_url, success: t(".post") }
          format.json { render :show, status: :ok, location: @resource }
        else
          format.html { render :edit, status: :unprocessable_entity, warning: t(".warning") }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /employees/1 or /employees/1.json
    def destroy
      if params[:all]
        DeleteAllJob.perform_later account: Current.account, resource_class: resource_class.to_s, sql_resources: @resources.to_sql
        respond_to do |format|
          format.html { redirect_to root_path, status: 303, success: t("delete_all_later") }
          format.json { head :no_content }
        end
      else
        cb = destroy_callback @resource
        eval(cb) if @resource.destroy!
        respond_to do |format|
          format.html { redirect_to resources_url, status: 303, success: t(".post") }
          format.json { head :no_content }
        end
      end
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
  end
end
