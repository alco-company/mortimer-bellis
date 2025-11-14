class RefreshErpTokenJob < ApplicationJob
  queue_as :default

  # args:
  #   tenant,
  #   user:
  #   from_at:
  #   to_at:
  #
  def perform(**args)
    super(**args)
    #
    # refresh the token for the tenant/user - if token needs refreshing
    #
    Dinero::Service.new.token_fresh?
  end
end
