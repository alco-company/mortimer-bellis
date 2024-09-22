class PagesController < MortimerController
  before_action :authorize, except: :show
  skip_before_action :authenticate_user!, only: :show
  skip_before_action :ensure_tenanted_user, only: :show

  def show
    user_signed_in? ?
      @resource = Page.find(params[:id]) :
      @resource = Page.find_by(slug: params[:id])
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:page).permit(:slug, :title, :content)
    end

    def authorize
      redirect_to root_path, alert: t(:unauthorized) unless current_user.superadmin?
    end
end
