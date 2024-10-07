class SyncErpCustomersJob < ApplicationJob
  queue_as :default

  # args:
  #   tenant,
  #   user:
  #   from_at:
  #   to_at:
  #
  def perform(**args)
    super(**args)
    user = args[:user]
    user_time_zone(user.time_zone) do
      ds = DineroService.new
      ds.pull resource_class: Customer, all: true, pageSize: 500
    end
  end
end
