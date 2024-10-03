class DineroController < ApplicationController
  skip_forgery_protection
  #
  # POST "/dinero/callback?code=DA4075B1BACB8D25C2394503E001215730F147C8009A2AB7709FD6849EF95C48&scope=dineropublicapi%3Awrite%20dineropublicapi%3Aread%20offline_access&iss=https%3A%2F%2Fconnect.visma.com" for 127.0.0.1 at 2024-09-30 22:50:54 +0200
  #
  def callback
    state = JSON.parse(Base64.decode64(params[:state]))
    if Current.find_user state["pos_token"]
      dinero_service = DineroService.new
      creds = { code: params[:code], pos_token: Current.user.pos_token }
      res = dinero_service.get_creds(creds: creds)
      if res[:result] && dinero_service.add_service("Dinero", res[:service_params])
        redirect_to state["path"], locals: { result: t("dinero_service_authorized") }
        # render turbo_stream: turbo_stream.replace("dinero", partial: "dinero/success", locals: { success: t("dinero_service_authorized") })
      else
        redirect_to state["path"], locals:  { result: t(res[:error]) }
        # render turbo_stream: turbo_stream.replace("dinero", partial: "dinero/failed", locals: { error: t(res[:error]) })
      end
    else
      redirect_to state["path"], locals:  { result: t("dinero_wrong_access_token") }
      # render turbo_stream: turbo_stream.replace("dinero", partial: "dinero/failed", locals: { error: t("dinero_wrong_access_token") })
    end
  end
end
