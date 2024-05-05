class PagesController < MortimerController
  skip_before_action :authenticate_user!, only: :show
  skip_before_action :ensure_accounted_user, only: :show

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
end
