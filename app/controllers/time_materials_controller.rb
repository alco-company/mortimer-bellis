class TimeMaterialsController < MortimerController
  def new
    super
    resource.initialize_new Current.get_user.get_hourly_rate, get_default_time_material_date
  end

  def index
    @resources = resources
    # if ActiveModel::Type::Boolean.new.cast(params[:show_all])
    #   @resources = @resources.order(wdate: :desc)
    # elsif params[:search].blank? && params[:s].blank? && params[:d].blank? && !(@filter.persisted? rescue false)
    #   my_open = @resources.where(user_id: Current.user.id).not_done_or_pushed
    #   @resources = (my_open.exists? ? my_open : @resources).order(wdate: :desc)
    # else
    @resources = @resources.order(wdate: :desc)
    # end
    super
  end

  def show
    process_reload or super
  end

  def edit
    resource.customer_name =  resource.customer&.name || resource.customer_name  # unless resource.customer_id.blank?
    resource.project_name =   resource.project&.name  || resource.project_name   # unless resource.project_id.blank?
    resource.product_name =   resource.product&.name  || resource.product_name   # unless resource.product_id.blank?
    super
    preprocess_time
  end

  # pick up the play button from the time_material#index view
  #
  def create
    # set_mileage
    create_play
    super
  end

  def sync
    status = sync_state

    respond_to do |format|
      format.json { render json: snapshot(@resource), status: status }
      format.turbo_stream {
        stream_update
        if @resource.done?
          @_action_name = "edit" && params[:action] = "edit"
          set_time
          render turbo_stream: [
            turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }),
            turbo_stream.replace("form", partial: "application/edit", locals: { resource: resource, tenant: Current.get_tenant, messages: flash, user: Current.get_user })
          ]
        else
          render turbo_stream: [ turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }) ]
        end
      }
    end
  end

  # POST /users/:id/archive
  # roadmapped for future use iaw sales
  #
  # def archive
  #   resource = TimeMaterial.find(params[:id])
  #   if resource
  #     resource.archived? ?
  #       (resource.pushed_to_erp! && notice = t("time_material.unarchived")) :
  #       (resource.archived! && notice = t("time_material.archived"))
  #     redirect_back(fallback_location: root_path, notice: notice)
  #     Broadcasters::Resource.new(resource, { controller: "time_materials" }).replace
  #   else
  #     redirect_back(fallback_location: root_path, warning: t("users.not_found"))
  #   end
  # end

  private

    def sync_state
      begin
        resource # ensures @resource is loaded
        ops = params.require(:ops)
        client_version = params[:version].to_i if params[:version]

        TimeMaterial.transaction do
          if client_version && @resource.lock_version != client_version
            return :conflict
          end

          ops.each do |op|
            case op[:type]
            when "sync"; next
            when "resume"
              @resource.resume!(at: Time.at(op[:at_ms].to_i / 1000.0)) && flash.now[:success] = t("time_material.resumed")
            when "paused"
              @resource.pause!(at: Time.at(op[:at_ms].to_i / 1000.0)) && flash.now[:success] = t("time_material.paused")
            when "pause_delta"
              @resource.add_elapsed_seconds!(op[:delta_sec].to_i)
              @resource.update!(started_at: nil, state: "paused")
            when "stop", "stopped"
              @resource.stop!(at: Time.at(op[:at_ms].to_i / 1000.0)) && flash.now[:success] = t("time_material.stopped")
            end
          end
        end
      rescue
        return :bad_request
      end

      :ok
    end

    # return JSON snapshot of the time_material record
    #
    def snapshot(rec)
      {
        id: rec.id,
        state: rec.state,
        total_seconds: rec.total_seconds,
        registered_minutes: rec.registered_minutes,
        started_at: rec.started_at&.iso8601,
        paused_at: rec.paused_at,
        time: rec.time,
        time_spent: rec.time_spent,
        minutes_reloaded_at: rec.minutes_reloaded_at,
        version: rec.lock_version
      }
    end

    def process_reload
      return false unless params.dig(:reload).present?
      status = sync_state
      render json: snapshot(resource), status: status
    end

    #
    # default_actions callbacks - called before and after create/update
    #
    def before_create_callback
      r = resource.prepare_tm resource_params
      return false if r == false
      resource_params(r)
      true
    end

    def resource_create
      resource.customer_id = resource_params[:customer_id]
      resource.project_id = resource_params[:project_id]
      resource.save
    end

    def create_callback
      postprocess_time
      true
    end

    def before_update_callback
      return false unless resource.user == Current.user or Current.user.admin? or Current.user.superadmin?
      r = resource.prepare_tm resource_params
      return false if r == false
      resource_params(r)
      true
    end

    def update_callback
      postprocess_time
      true
    end

    def stream_create
      ut, usa, t, sa = find_target_action

      Broadcasters::Resource.new(resource,
        params.permit!,
        target: ut,
        stream_action: usa,
        user: Current.user,
        stream: "#{Current.user.id}_time_materials").create unless ut.nil?
      Current.get_tenant.users.filter { |u| u != Current.user }.each do |u|
        next unless u.signed_in?
        Broadcasters::Resource.new(resource, params.permit!, target: t, stream_action: sa, user: u, stream: "#{u.id}_time_materials").create
      end unless t.nil?
    end

    def stream_update(usr = Current.user)
      Broadcasters::Resource.new(resource, params.permit!, user: usr, stream: "#{usr.id}_time_materials").replace
      Current.get_tenant.users.filter { |u| u != usr }.each do |u|
        next unless u.signed_in?
        Broadcasters::Resource.new(resource, params.permit!, user: u, stream: "#{u.id}_time_materials").replace
      end
    end

    def stream_destroy
      Broadcasters::Resource.new(resource, user: Current.user, stream: "#{Current.user.id}_time_materials").destroy
      Current.get_tenant.users.each do |u|
        next unless u.current_sign_in_at.present? && u != Current.user
        Broadcasters::Resource.new(resource, user: u, stream: "#{u.id}_time_materials").destroy
      end
    end

    def find_target_action
      recs = resources.where(wdate: resource.wdate)
      total_recs = recs.count
      if total_recs > 1
        ut = "time_material_#{recs.order(wdate: :desc).second.id}"
        t = "TimeMaterial_#{resource.wdate}"
        sa = :append
        usa = :before
        return [ ut, usa, t, sa ]
      end
      return [ nil, nil, nil, nil ] if total_recs < 1

      # recs = "TimeMaterial.where(tenant_id: #{Current.get_tenant.id}).order(wdate: :desc)"

      Broadcasters::Resource.new(resource, params.permit!, partial: "time_materials/wdate", target: "record_list", stream_action: :prepend, user: Current.user, stream: "#{Current.user.id}_time_materials").create
      Current.get_tenant.users.filter { |u| u != Current.user }.each do |u|
        next unless u.signed_in?
        Broadcasters::Resource.new(resource, params.permit!, partial: "time_materials/wdate", target: "record_list", stream_action: :prepend, user: u, stream: "#{u.id}_time_materials").create
      end
      [ nil, nil, nil, nil ]
      # ut = nil
      # t = ut = "record_list"
      # sa = usa = :prepend
      # [ ut, usa, t, sa ]
    end

    # called before showing the edit form
    # fix hour_time, minute_time, registered_minutes, started_at, time_spent
    # user can edit from an active or paused, other state
    # after hitting the 'edit' context_menu button
    # or after hitting the 'stop' button
    #
    def preprocess_time
      set_time
      resource_params[:hour_time] = resource.hour_time
      resource_params[:minute_time] = resource.minute_time
      # ht, mt = resource.time.split(":")
      # resource_params[:registered_minutes] = ht.to_i * 60 + mt.to_i
      # resource_params[:started_at] = resource.started_at
      # resource_params[:time_spent] = resource.time_spent
    end

    # called after create or update of a time_material
    # hour_time, minute_time, registered_minutes, started_at, time_spent should be set straight
    # making sure that time is in sync with registered_minutes
    #
    def postprocess_time
      return unless resource.is_time?
      ht, mt = resource.time.split(":").map(&:to_i).each_with_index { |v, i| i==0 ? v : v.clamp(0, 59) }
      resource.registered_minutes = ht * 60 + mt
      resource.started_at = resource.registered_minutes.minutes.ago
      resource.minutes_reloaded_at = Time.current
      resource.save
    end

    def create_play
      return unless params[:play].present?
      # ht, mt = resource.sanitize_time("0", "0").split(":")

      params[:time_material] = {
        time: "0",
        state: 1,
        user_id: Current.user.id,
        started_at: Time.current,
        paused_at: nil,
        time_spent: 0,
        hour_time: 0,
        minute_time: 0,
        rate: Current.get_user.get_hourly_rate,
        registered_minutes: 0,
        date: get_default_time_material_date,
        about: Current.user.default(:default_time_material_about, "")
      }
      params.delete(:play)
      params[:played] = true
    end

    # Only allow a list of trusted parameters through.
    def resource_params(rp = nil)
      return params unless params[:time_material].present?

      # set params if rp
      if rp
        params[:time_material] = rp
      end
      params.expect(time_material: [
        :tenant_id,
        :date,
        :hour_time,
        :minute_time,
        :over_time,
        :about,
        :user_id,
        :customer_name,
        :customer_id,
        :project_name,
        :project_id,
        :product_name,
        :product_id,
        :quantity,
        :rate,
        :unit_price,
        :unit,
        :discount,
        :comment,
        :state,
        :time_spent,
        :started_at,
        :paused_at,
        # :odo_from,
        # :odo_to,
        # :kilometers,
        # :trip_purpose,
        # :odo_from_time,
        # :odo_to_time,
        :is_invoice,
        :is_free,
        :is_offer,
        :is_separate,
        :tag_list,
        :task_comment,
        :location_comment
      ])
    end

    def set_time
      # total_minutes = (resource.elapsed_seconds_now / 60 rescue 0)
      total_minutes = resource.total_seconds / 60
      ht, mt = total_minutes.divmod(60) # total_minutes.divmod(60)
      if Current.user.should?(:limit_time_to_quarters)
        mt = case mt
        when 0; ht==0 ? 15 : 0
        when 1..15; 15
        when 16..30; 30
        when 31..45; 45
        else; ht += 1; 0
        end
      end

      if Current.get_user.should? :fill_play_time_in_time_fields
        resource.hour_time = ht
        resource.minute_time = mt
        resource.registered_minutes = ht * 60 + mt
        resource.minutes_reloaded_at = Time.current
      end
      resource.save
    end

    def stream_it_all
      render turbo_stream: [
        turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }),
        turbo_stream.replace("form", partial: "application/edit", locals: { resource: resource, tenant: Current.get_tenant, messages: flash, user: Current.get_user })
      ]
    end

    def get_default_time_material_date
      dt=Current.get_user.default(:default_time_material_date, "Time.current.to_date")
      if dt =~ /.to_date/
        parts = dt.split(".")
        eval(parts.join(".")).class == Date ? eval(parts.join(".")) : Time.current.to_date
      else
        raise "no date expected"
      end
    rescue
      Time.current.to_date
    end
end
