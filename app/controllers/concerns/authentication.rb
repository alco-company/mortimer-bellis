module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :ensure_accounted_user
  end

  #
  # TODO Implement User.find_by_valid_session(session)
  #
  def ensure_accounted_user
    Current.user = current_user
  rescue
    redirect_to new_user_session_path
    # Current.account = Account.first
    # if (user = User.find_by_valid_session(session))
    #   Current.user = user
    # else
    #   redirect_to signin_path
    # end
  end
end
