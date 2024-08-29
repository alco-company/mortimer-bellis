class DeleteAllJob < ApplicationJob
  queue_as :default

  # args: account, sql_resources
  #
  def perform(**args)
    super(**args)
    rc = args[:resource_class].constantize
    resource = rc.by_account(args[:account]).first
    switch_locale do
      resources = execute_statement args[:sql_resources]
      ids = resources.collect { |r| r["id"] }.compact
      if ids.any?
        ar = rc.where(id: ids)
        ar.destroy_all
        Broadcasters::Resource.new(resource).destroy_all
      end
    end
  end
end
