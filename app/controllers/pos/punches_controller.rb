class Pos::PunchesController < Pos::PosController
  around_action :punch_clock_time_zone
  # before_action :verify_user, only: :index
  layout false

  def index
    first_punch = Punch.find(params[:id])
    @resource = first_punch.punch_clock
    if first_punch
      user = first_punch.user
      date_range = first_punch.punched_at.beginning_of_day..first_punch.punched_at.end_of_day
      @punches = Punch.where(user: user, punched_at: date_range)
      render turbo_stream: turbo_stream.replace("date_#{helpers.dom_id(first_punch)}", partial: "pos/punches/index")
    else
      head :not_found
    end
  end

  private
    def verify_user
      @user = case true
      when params[:user_id].present?; User.by_tenant.find(params.delete(:user_id))
      when params[:user].present?; User.by_tenant.find(params[:user][:id])
      when params[:q].present?; User.by_tenant.find_by(pincode: params[:q])
      else nil
      end
      redirect_to pos_punch_clock_path(api_key: @resource.access_token) and return unless @user
    end

    def punch_clock_time_zone(&block)
      timezone = @resource.time_zone rescue nil
      timezone.blank? ?
        Time.use_zone("UTC", &block) :
        Time.use_zone(timezone, &block)
    end
end
