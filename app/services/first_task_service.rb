class FirstTaskService
  attr_reader :tenant, :user
  def initialize(tenant, user)
    @tenant = tenant
    @user = user
  end

  def check
    Task.where(tenant_id: 1).first_tasks.each do |first_task|
      build_tenant_task(first_task) if first_task.priority > -100 && !user.user?
      build_user_task(first_task) if first_task.priority < -99
    end
  end

  # validate that all tasks are done
  def validate
    user.tasks.first_tasks.uncompleted.each do |task|
      task.update completed_at: Time.current if eval(task.validation)
    end
  end

  #
  # tasks from -1 to -99 are for the admin user only
  #
  def build_tenant_task(first_task)
    unless user.tasks.first_tasks.map(&:priority).include?(first_task.priority)
      first_task = first_task.attributes.symbolize_keys.except! :id, :created_at, :updated_at, :tenant_id, :completed_at
      first_task = Task.build(first_task)
      first_task.tenant = tenant
      first_task.tasked_for = user
      first_task.save
    end
  end

  #
  # tasks from -100 to -999 are for all users
  #
  def build_user_task(first_task)
    unless user.tasks.first_tasks.map(&:priority).include?(first_task.priority)
      first_task = first_task.attributes.symbolize_keys.except! :id, :created_at, :updated_at, :tenant_id, :completed_at
      first_task = Task.build(first_task)
      first_task.tenant = tenant
      first_task.tasked_for = user
      first_task.save
    end
  end
end
