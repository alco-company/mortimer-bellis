module DefaultActions
  extend ActiveSupport::Concern

  included do
    before_action :set_resource, only: %i[ new show edit update destroy ]
    before_action :set_filter, only: %i[ index ]
    before_action :set_resources, only: %i[ index ]

    # GET /employees or /employees.json
    def index
      params[:url] = resources_url
      @pagy, @records = pagy(@resources)

      respond_to do |format|
        format.html { }
        format.csv { send_data resource_class.to_csv( @resources), filename: "#{resource_class.name.pluralize.downcase}-#{Date.today}.csv" }
      end
    end

    # GET /employees/1 or /employees/1.json
    def show
    end

    # GET /employees/new
    def new
    end

    # GET /employees/1/edit
    def edit
    end

    # POST /employees or /employees.json
    def create
      @resource = resource_class.new(resource_params)

      respond_to do |format|
        if @resource.save
          create_callback @resource
          format.html { redirect_to resources_url, notice: t('.post') }
          format.json { render :show, status: :created, location: @resource }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /employees/1 or /employees/1.json
    def update
      respond_to do |format|
        if @resource.update(resource_params)
          update_callback @resource
          format.html { redirect_to resources_url, notice: t('.post') }
          format.json { render :show, status: :ok, location: @resource }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /employees/1 or /employees/1.json
    def destroy
      @resource.destroy!

      respond_to do |format|
        format.html { redirect_to resources_url, notice: t('.post') }
        format.json { head :no_content }
      end
    end

    #
    # implement on the controller inheriting this concern
    def create_callback obj
    end
    def update_callback obj
    end
  end
end
