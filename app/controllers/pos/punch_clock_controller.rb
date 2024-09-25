class Pos::PunchClockController < Pos::PosController
  before_action :verify_token
  before_action :verify_employee, except: :show

  around_action :punch_clock_time_zone, only: [ :edit, :show ]

  def show
  end

  #
  # {"api_key"=>"[FILTERED]", "q"=>"1234", "id"=>"1"}
  def edit
  end

  #
  # Parameters: {"authenticity_token"=>"[FILTERED]", "punch_clock"=>{"api_key"=>"[FILTERED]"}, "employee"=>{"state"=>"IN", "id"=>"1"}, "button"=>"", "id"=>"1"}
  def create
    redirect_to(pos_punch_clock_path(api_key: @resource.access_token, q: @user.pincode), warning: t("user.archived")) and return if @user.archived?
    redirect_to(pos_punch_clock_path(api_key: @resource.access_token, q: @user.pincode), warning: t("user.blocked")) and return if @user.is_blocked?

    if params[:user][:state] == @user.state
      redirect_to pos_punch_clock_url(api_key: @resource.access_token, q: @user.pincode), warning: t("state_eq_current_state") and return
    end
    @user.punch @resource, params[:user][:state], request.remote_ip
    @user.update state: params[:user][:state]
    redirect_to pos_punch_clock_url(api_key: @resource.access_token)
  end

  private

    def verify_employee
      @user = case true
      when params[:user_id].present?; User.by_tenant.find(params.delete(:user_id))
      when params[:user].present?; User.by_tenant.find(params[:user][:id])
      when params[:q].present?; User.by_tenant.find_by(pincode: params[:q])
      else nil
      end
      redirect_to pos_punch_clock_path(api_key: @resource.access_token) and return unless @user
    end

    def verify_token
      api_key = case true
      when params[:api_key].present?; params.delete(:api_key)
      when params[:punch_card].present?; params[:punch_card].delete(:api_key)
      when params[:punch_clock].present?; params[:punch_clock].delete(:api_key)
      else ""
      end
      @resource = PunchClock.by_tenant.find_by(access_token: api_key)
      redirect_to root_path and return if @resource.nil?
      Current.tenant = @resource.tenant
      # @resource.regenerate_access_token
    end

    def punch_clock_time_zone(&block)
      timezone = @resource.time_zone rescue nil
      timezone.blank? ?
        Time.use_zone("UTC", &block) :
        Time.use_zone(timezone, &block)
    end
end
