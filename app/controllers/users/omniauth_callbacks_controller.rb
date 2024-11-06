# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include TimezoneLocale
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # request.env["omniauth.auth"]["extra"]["raw_info"] =>
  # {"aud"=>"00000003-0000-0000-c000-000000000000",
  # "iss"=>"https://sts.windows.net/d4c705d3-d11d-4373-ad79-0e18a0fa8725/",
  # "iat"=>1730193327,
  # "nbf"=>1730193327,
  # "exp"=>1730198249,
  # "email"=>"walther@alco.dk",
  # "name"=>"Walther Diechmann",
  # "oid"=>"dc39581f-c1b0-4111-8388-851688c9529c",
  # "preferred_username"=>"walther@alco.dk",
  # "rh"=>"0.AQwA0wXH1B3Rc0OteQ4YoPqHJQMAAAAAAAAAwAAAAAAAAADdAC0.",
  # "sub"=>"3bAaSPcO3H3gde_4rvsf2svE_DEH0Ix25su22oUkJHY",
  # "tid"=>"d4c705d3-d11d-4373-ad79-0e18a0fa8725",
  # "uti"=>"m1RRLW6wc0CfYC690B4PAA",
  # "ver"=>"1.0",
  # "acct"=>0,
  # "acr"=>"1",
  # "aio"=>"AVQAq/8YAAAAidE3dJfjoMpCvcDg7wW+M80CSam7P781o+pp36MK8a4ICvi/E8ROqv2TwC1/QJbldDX1wLbpommuXl0d3Jnt37ULuG9MxhnM7a8uc1Zv8PA=",
  # "amr"=>["pwd", "mfa"],
  # "app_displayname"=>"Mortimer",
  # "appid"=>"9cff0add-b5b9-4029-8d2d-4c0fc8b0710d",
  # "appidacr"=>"1",
  # "family_name"=>"Diechmann",
  # "given_name"=>"Walther",
  # "idtyp"=>"user",
  # "ipaddr"=>"85.191.122.210",
  # "platf"=>"5",
  # "puid"=>"100300008A0711EB",
  # "scp"=>"email openid profile",
  # "signin_state"=>["kmsi"],
  # "tenant_region_scope"=>"EU",
  # "unique_name"=>"walther@alco.dk",
  # "upn"=>"walther@alco.dk",
  # "wids"=>["62e90394-69f5-4237-9190-012177145e10", "b79fbf4d-3ef9-4689-8143-76b194e85509"],
  # "xms_idrel"=>"1 12",
  # "xms_st"=>{"sub"=>"k31fRTGwA_CPQgCa0po_2n4lfe-N-026ddXfSyPLUtU"},
  # "xms_tcdt"=>1400834163,
  # "xms_tdbr"=>"EU"}
  def entra_id
    email = request.env["omniauth.auth"]["extra"]["raw_info"]["email"]
    user = User.find_by(email: email)
    if user
      user.update(confirmed_at: Time.current) if user.confirmed_at.nil?
      User.accept_invitation!(invitation_token: user.invitation_token) if user.invitation_accepted_at.nil?
      flash[:notice] = t("devise.omniauth_callbacks.success", kind: "Microsoft Entra ID", email: email)
      sign_in_and_redirect user, event: :authentication
    else
      reason = t("devise.omniauth_callbacks.user_not_found", email: email)
      flash[:warning] = t("devise.omniauth_callbacks.failure", kind: "Microsoft Entra ID", reason: reason)
      redirect_to new_user_session_url
    end
  end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  def after_omniauth_failure_path_for(scope)
    super(scope)
  end
end
