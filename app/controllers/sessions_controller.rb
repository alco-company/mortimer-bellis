# frozen_string_literal: true

class SessionsController < BaseController
  include TimezoneLocale
  before_action :authenticate_user!, only: [ :check ]

  # called by the client side to check if the session is still valid
  def check
    # return unless user_signed_in?

    if Time.now > Current.user.last_sign_in_at + 7.days
      sign_out(Current.user)
      head :unauthorized
    else
      head :ok
    end
  rescue
    head :unauthorized
  end
end
