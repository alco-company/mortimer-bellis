namespace :tenant do
  def env_bool(key, default = false)
    val = ENV[key]
    return default if val.nil?
    %w[1 true yes y on].include?(val.downcase)
  end

  desc "Backup tenant. ENV: TENANT=<id> TUID=<id optional> [PERFORM_NOW=1]"
  task backup: :environment do
    tenant_id = ENV["TENANT"] or raise "TENANT required"
    tenant = Tenant.find(tenant_id)
    user = ENV["TUID"] ? User.find(ENV["TUID"]) : (tenant.users.first || User.first)
    perform_now = env_bool("PERFORM_NOW", false) || env_bool("NOW", false) || env_bool("SYNC", false)
    bg = BackgroundJob.create!(tenant: tenant, user: user, job_klass: "BackupTenantJob", state: :planned)
    if perform_now
      jid = "inline-#{SecureRandom.hex(6)}"
      bg.update_column(:job_id, jid)
      bg.running! # update!(state: :running)
      # job = BackupTenantJob.new
      job.instance_variable_set(:@job_id, jid)
      job.perform(tenant: tenant, user: user, background_job: bg)
      bg.update!(state: :finished)
      bg.job_done
      puts "Ran BackupTenantJob inline job_id=#{jid} background_job_id=#{bg.id}"
    else
      job = BackupTenantJob.perform_later(tenant: tenant, user: user, background_job: bg)
      bg.update_column(:job_id, job.job_id)
      puts "Enqueued BackupTenantJob job_id=#{job.job_id} background_job_id=#{bg.id}"
    end
  end

  desc "Restore tenant. ENV: TENANT=<id> ARCHIVE=<path> [TUID=<id>] [DRY_RUN=true/false] [PURGE=true/false] [RESTORE=true/false] [REMAP=true/false] [SKIP_EMAIL=true/false] [PERFORM_NOW=1] [STRICT=true/false]"
  task restore: :environment do
    tenant_id = ENV["TENANT"] or raise "TENANT required"
    archive = ENV["ARCHIVE"] or raise "ARCHIVE required"
    raise "Archive file not found" unless File.exist?(archive)

    puts "[rake restore] DB path: #{ActiveRecord::Base.connection_db_config.configuration_hash[:database]} ENV=#{Rails.env}"

    begin
      tenant = Tenant.find(tenant_id)
    rescue ActiveRecord::RecordNotFound
      force = env_bool("FORCE", false)
      if force
        remap = true
        tenant = Tenant.new(id: tenant_id, name: "Restored Tenant #{tenant_id}")
        tenant.save(validate: false)
        puts "Created placeholder tenant id=#{tenant.id} via FORCE=1"
      else
        abort <<~MSG
        Tenant #{tenant_id} not found.
        Either:
          A) Re-run with FORCE=1 to auto-create a placeholder tenant with that id, keeping original tenant_id values, or
          B) Choose an existing tenant id: TENANT=<existing_id> REMAP=true (default) to remap all records to that tenant.
        Aborting without FORCE to prevent accidental creation.
        MSG
      end
    end

    user = ENV["TUID"] ? User.find(ENV["TUID"]) : (tenant.users.first || User.first)
    dry_run = env_bool("DRY_RUN", false)
    purge = env_bool("PURGE", false)
    strict = env_bool("STRICT", false)
    restore_flag = env_bool("RESTORE", true)
    remap = env_bool("REMAP", true) unless defined?(remap) && remap == true
    skip_email = env_bool("SKIP_EMAIL", false)
    perform_now = env_bool("PERFORM_NOW", false) || env_bool("NOW", false) || env_bool("SYNC", false)
    bg = BackgroundJob.create!(tenant: tenant, user: user, job_klass: "RestoreTenantJob", state: :planned)
    if perform_now
      jid = "inline-#{SecureRandom.hex(6)}"
      bg.update_column(:job_id, jid)
      bg.update!(state: :running)
      job = RestoreTenantJob.new
      job.instance_variable_set(:@job_id, jid)
      job.perform(tenant: tenant, user: user, archive_path: archive, strict: strict, dry_run: dry_run, purge: purge, restore: restore_flag, remap: remap, skip_email: skip_email, background_job: bg)
      bg.update!(state: :finished)
      bg.job_done
      puts "Ran RestoreTenantJob inline job_id=#{jid} background_job_id=#{bg.id} dry_run=#{dry_run} purge=#{purge} restore=#{restore_flag} remap=#{remap}"
    else
      job = RestoreTenantJob.perform_later(tenant: tenant, user: user, archive_path: archive, strict: strict, dry_run: dry_run, purge: purge, restore: restore_flag, remap: remap, skip_email: skip_email, background_job: bg)
      bg.update_column(:job_id, job.job_id)
      puts "Enqueued RestoreTenantJob job_id=#{job.job_id} background_job_id=#{bg.id} dry_run=#{dry_run} purge=#{purge} restore=#{restore_flag} remap=#{remap}"
    end
  end
end
