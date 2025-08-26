class BackupTenantJob < ApplicationJob
  queue_as :default

  def log_progress(step:, **data)
    return unless @background_job
    payload = { step: step, at: Time.now.utc.iso8601 }.merge(data)
    begin
      current = JSON.parse(@background_job.job_progress || '{}') rescue {}
      current['log'] ||= []
      current['log'] << payload
      current['log'] = current['log'].last(100)
      @background_job.update_column(:job_progress, current.to_json)
    rescue
    end
  end

  def perform(**args)
    super(**args)
    tenant = @tenant
    return unless tenant

    log_progress(step: :start)

    Rails.application.eager_load! unless Rails.application.config.eager_load

    timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
    label = "tenant_#{tenant.id}_#{timestamp}"
    base_dir = Rails.root.join("tmp", label)
    FileUtils.mkdir_p(base_dir)

    manifest = []
    log_progress(step: :scan_tables)

    connection = ActiveRecord::Base.connection
    tables = connection.tables
    tenant_tables = tables.select do |t|
      connection.columns(t).map(&:name).include?("tenant_id")
    end

    models_by_table = {}
    ActiveRecord::Base.descendants.each do |m|
      next unless m.respond_to?(:table_name)
      models_by_table[m.table_name] = m
    end

    dump_path = base_dir.join("dump.jsonl")
    processed = 0
    File.open(dump_path, "w") do |f|
      tenant_tables.sort.each do |table|
        model = models_by_table[table]
        model = nil if model && model.abstract_class?
        begin
          if model
            count = model.unscoped.where(tenant_id: tenant.id).count
            next if count == 0
            model.unscoped.where(tenant_id: tenant.id).find_in_batches(batch_size: 500) do |batch|
              batch.each { |rec| f.puts({ model: model.name, data: rec.attributes }.to_json) }
              processed += batch.size
              log_progress(step: :dump_progress, table: table, processed: processed)
            end
            manifest << { table: table, model: model.name, count: count }
          else
            rows = connection.exec_query("SELECT * FROM #{table} WHERE tenant_id = #{tenant.id}")
            next if rows.rows.empty?
            rows.to_a.each { |row| f.puts({ model: table, data: row }.to_json) }
            processed += rows.rows.size
            log_progress(step: :dump_progress, table: table, processed: processed)
            manifest << { table: table, model: nil, count: rows.rows.size }
          end
        rescue => e
          manifest << { table: table, model: (model&.name), error: e.message }
          log_progress(step: :error, table: table, message: e.message)
        end
      end
    end

    File.write(base_dir.join("manifest.json"), JSON.pretty_generate(manifest))
    log_progress(step: :manifest_written, entries: manifest.size)

    if defined?(ActiveStorage::Attachment)
      log_progress(step: :active_storage_scan)
      attachment_file = base_dir.join("active_storage_attachments.jsonl")
      blob_file = base_dir.join("active_storage_blobs.jsonl")
      tenant_attachment_ids = []
      File.open(attachment_file, "w") do |fa|
        ActiveStorage::Attachment.includes(:blob, :record).find_each(batch_size: 500) do |att|
          rec = att.record rescue nil
          if rec && rec.respond_to?(:tenant_id) && rec.tenant_id == tenant.id
            fa.puts(att.attributes.to_json)
            tenant_attachment_ids << att.blob_id if att.blob_id
          end
        end
      end
      log_progress(step: :active_storage_attachments, count: tenant_attachment_ids.size)
      tenant_blob_ids = tenant_attachment_ids.uniq
      File.open(blob_file, "w") do |fb|
        ActiveStorage::Blob.where(id: tenant_blob_ids).find_each(batch_size: 500) do |blob|
          fb.puts(blob.attributes.to_json)
        end
      end
      log_progress(step: :active_storage_blobs, count: tenant_blob_ids.size)
      begin
        service = ActiveStorage::Blob.service
        if service.respond_to?(:path_for)
          storage_dir = base_dir.join("blobs")
          copied = 0
          tenant_blob_ids.each do |bid|
            blob = ActiveStorage::Blob.find_by(id: bid)
            next unless blob
            src = service.path_for(blob.key) rescue nil
            next unless src && File.exist?(src)
            dest_dir = storage_dir.join(blob.key[0, 2], blob.key[2, 2], blob.key[4, 2])
            FileUtils.mkdir_p(dest_dir)
            FileUtils.cp(src, dest_dir.join(blob.key))
            copied += 1
            log_progress(step: :active_storage_copy_progress, copied: copied) if (copied % 10).zero?
          end
          log_progress(step: :active_storage_copy_done, copied: copied)
        end
      rescue => e
        manifest << { active_storage_copy_error: e.message }
        log_progress(step: :error, phase: :active_storage_copy, message: e.message)
      end
    end

    archive_path = Rails.root.join("tmp", "#{label}.tar.gz")
    Dir.chdir(base_dir.dirname) do
      system("tar -czf #{archive_path} #{label}")
    end
    log_progress(step: :archive_created, path: archive_path.to_s)

    begin
      TenantMailer.with(tenant: tenant, link: archive_path.to_s).backup_created.deliver_later
      log_progress(step: :email_enqueued)
    rescue => e
      say "BackupTenantJob email failed: #{e.message}"
      log_progress(step: :error, phase: :email, message: e.message)
    end

    archive_path
  rescue => e
    say "BackupTenantJob failed: #{e.message}"
    log_progress(step: :failed, message: e.message)
    UserMailer.error_report(e.full_message, "BackupTenantJob#perform").deliver_later rescue nil
  end
end

