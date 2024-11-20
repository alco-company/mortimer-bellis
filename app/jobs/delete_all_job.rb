class DeleteAllJob < ApplicationJob
  queue_as :default

  # args: tenant, sql_resources
  #
  def perform(**args)
    super(**args)
    rc = args[:resource_class].constantize
    resource = rc.by_tenant(args[:tenant]).first
    switch_locale do
      resources = execute_statement args[:sql_resources]
      ids = resources.collect { |r| r["id"] }.compact
      if ids.any?
        ActiveRecord::Base.connected_to(role: :writing) do
          # All code in this block will be connected to the reading role.
          ar = rc.where(id: ids)
          ar.destroy_all
          Broadcasters::Resource.new(resource).destroy_all
        end
      end
    end
  end
end
