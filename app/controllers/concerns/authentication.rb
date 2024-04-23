module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :ensure_authenticated_user
  end

  #
  # TODO Implement User.find_by_valid_session(session)
  #
  def ensure_authenticated_user
    Current.account = Account.first
    # if (user = User.find_by_valid_session(session))
    #   Current.user = user
    # else
    #   redirect_to signin_path
    # end
  end
end