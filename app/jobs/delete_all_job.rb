class DeleteAllJob < ApplicationJob
  queue_as :default

  # args: tenant, ids, user_ids, resource_class
  #
  def perform(**args)
    super(**args)
    rc = args[:resource_class].constantize
    user_ids = args[:user_ids].present? ? args[:user_ids].compact : nil
    ids = args[:ids].compact
    # set the batch to be deleted if resources was selected by batch
    @batch = args[:batch] rescue nil
    switch_locale do
      resources = rc.where id: ids
      user_ids ||= rc.first.respond_to?(:user_id) ? resources.pluck(:user_id).uniq : []
      rc == Setting ?
        reset_settings :
        delete_all(rc, ids, user_ids) if ids.any?
    end
  rescue => e
    UserMailer.error_report(e.to_s, "DeleteAllJob#perform #{rc}").deliver_later
  end

  def reset_settings
    Setting.where(tenant: Current.tenant).destroy_all
    Setting.create_defaults_for_new Current.tenant
  end

  def delete_all(rc, ids, user_ids)
    ActiveRecord::Base.connected_to(role: :writing) do
      # All code in this block will be connected to the writing role.
      ar = rc.where(id: ids)
      tmp_resource = rc.build ar.first.attributes
      ar.each do |r|
        if @user.allowed_to?(:destroy, r)
          t = r.dup
          t.id=r.id
          begin
            r.destroy
            Broadcasters::Resource.new(t).destroy
          rescue => e
            Broadcasters::Resource.new(t).flash error: "DeleteAllJob failed on #{rc}##{t.id}: #{e.message}", user: @user
          end
        else
          Broadcasters::Resource.new(t).flash warning: "DeleteAllJob failed on #{rc}##{t.id} because you do not have permission", user: @user
        end
      end
      notify_all user_ids, tmp_resource
      tmp_resource.destroy
      @batch.delete if @batch
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
