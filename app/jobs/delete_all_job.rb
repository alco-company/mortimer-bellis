class DeleteAllJob < ApplicationJob
  queue_as :default

  # args: tenant, ids, user_ids, resource_class
  #
  def perform(**args)
    super(**args)
    rc = args[:resource_class].constantize
    user_ids = args[:user_ids].present? ? args[:user_ids].compact : nil
    ids = args[:ids].compact
    switch_locale do
      resources = rc.where id: ids
      user_ids ||= rc.first.respond_to?(:user_id) ? resources.pluck(:user_id).uniq : []
      delete_all(rc, ids, user_ids) if ids.any?
    end
  rescue => e
    UserMailer.error_report(e.to_s, "DeleteAllJob#perform #{rc}").deliver_later
  end

  def delete_all(rc, ids, user_ids)
    ActiveRecord::Base.connected_to(role: :writing) do
      # All code in this block will be connected to the writing role.
      ar = rc.where(id: ids)
      tmp_resource = rc.build ar.first.attributes
      ar.destroy_all
      notify_all user_ids, tmp_resource
      Broadcasters::Resource.new(tmp_resource).destroy_all
      tmp_resource.destroy
    end
  end

  def notify_all(user_ids, resource)
    name = resource.class.name
    user_ids.each do |user_id|
      user = user_id.is_a?(User) ?
        user_id :
        User.find(user_id)
      user.notify(action: :destroy_all, title: "DeleteAllJob", msg: "Someone deleted all #{name}!", rcp: user) if user
    end
  end
end
