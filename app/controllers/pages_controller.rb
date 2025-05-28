class PagesController < MortimerController
  skip_before_action :require_authentication, only: [ :show, :help ]
  skip_before_action :authorize, only: [ :show, :help ]

  def show
    Current.user ?
      @resource = Page.find(params[:id]) :
      @resource = Page.find_by(slug: params[:id])
    # render :show, layout: "apple_watch" if request.subdomain == "watch"
  end

  def help
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(page: [ :slug, :title, :content ])
    end
end
