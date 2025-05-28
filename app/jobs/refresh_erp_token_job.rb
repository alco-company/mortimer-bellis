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
    Dinero::Service.new.token_fresh?
  end
end
