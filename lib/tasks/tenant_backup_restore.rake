namespace :tenant do
  def env_bool(key, default = false)
    val = ENV[key]
    return default if val.nil?
    %w[1 true yes y on].include?(val.downcase)
  end

  desc 'Backup tenant. ENV: TENANT=<id> USER=<id optional> [PERFORM_NOW=1]'
  task backup: :environment do
    tenant_id = ENV['TENANT'] or raise 'TENANT required'
    tenant = Tenant.find(tenant_id)
    user = ENV['USER'] ? User.find(ENV['USER']) : (tenant.users.first || User.first)
    perform_now = env_bool('PERFORM_NOW', false) || env_bool('NOW', false) || env_bool('SYNC', false)
    bg = BackgroundJob.create!(tenant: tenant, user: user, job_klass: 'BackupTenantJob', state: :planned)
    if perform_now
      jid = "inline-#{SecureRandom.hex(6)}"
      bg.update_column(:job_id, jid)
      job = BackupTenantJob.new
      job.instance_variable_set(:@job_id, jid)
      job.perform(tenant: tenant, user: user, background_job: bg)
      puts "Ran BackupTenantJob inline job_id=#{jid} background_job_id=#{bg.id}"
    else
      job = BackupTenantJob.perform_later(tenant: tenant, user: user, background_job: bg)
      bg.update_column(:job_id, job.job_id)
      puts "Enqueued BackupTenantJob job_id=#{job.job_id} background_job_id=#{bg.id}"
    end
  end

  desc 'Restore tenant. ENV: TENANT=<id> ARCHIVE=<path> [USER=<id>] [DRY_RUN=true/false] [PURGE=true/false] [RESTORE=true/false] [REMAP=true/false] [SKIP_EMAIL=true/false] [PERFORM_NOW=1]'
  task restore: :environment do
    tenant_id = ENV['TENANT'] or raise 'TENANT required'
    archive = ENV['ARCHIVE'] or raise 'ARCHIVE required'
    raise 'Archive file not found' unless File.exist?(archive)
    tenant = Tenant.find(tenant_id)
    user = ENV['USER'] ? User.find(ENV['USER']) : (tenant.users.first || User.first)
    dry_run = env_bool('DRY_RUN', false)
    purge = env_bool('PURGE', false)
    restore_flag = env_bool('RESTORE', true)
    remap = env_bool('REMAP', true)
    skip_email = env_bool('SKIP_EMAIL', false)
    perform_now = env_bool('PERFORM_NOW', false) || env_bool('NOW', false) || env_bool('SYNC', false)
    bg = BackgroundJob.create!(tenant: tenant, user: user, job_klass: 'RestoreTenantJob', state: :planned)
    if perform_now
      jid = "inline-#{SecureRandom.hex(6)}"
      bg.update_column(:job_id, jid)
      job = RestoreTenantJob.new
      job.instance_variable_set(:@job_id, jid)
      job.perform(tenant: tenant, user: user, archive_path: archive, dry_run: dry_run, purge: purge, restore: restore_flag, remap: remap, skip_email: skip_email, background_job: bg)
      puts "Ran RestoreTenantJob inline job_id=#{jid} background_job_id=#{bg.id} dry_run=#{dry_run} purge=#{purge} restore=#{restore_flag} remap=#{remap}"
    else
      job = RestoreTenantJob.perform_later(tenant: tenant, user: user, archive_path: archive, dry_run: dry_run, purge: purge, restore: restore_flag, remap: remap, skip_email: skip_email, background_job: bg)
      bg.update_column(:job_id, job.job_id)
      puts "Enqueued RestoreTenantJob job_id=#{job.job_id} background_job_id=#{bg.id} dry_run=#{dry_run} purge=#{purge} restore=#{restore_flag} remap=#{remap}"
    end
  end
end
