module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_current_user
  end


  # just checking if the user is signed in
  # they may have a session -
  #
  def set_current_user
    if user_signed_in?
      Current.user = current_user
      Current.tenant = current_user.tenant
    end
  end

  #
  # TODO Implement User.find_by_valid_session(session)
  #
  # def ensure_tenanted_user
  #   Current.user = current_user
  # rescue
  #   redirect_to new_user_session_path
  # end
end
