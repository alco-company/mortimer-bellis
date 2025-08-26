class RestoreTenantJob < ApplicationJob
  queue_as :default

  # args: tenant: (target tenant), user:, archive_path: "/full/path/to/tar.gz", remap: true/false
  # If remap is true and the dump tenant_id differs from target tenant.id, tenant_id is replaced.
  def perform(**args)
    super(**args)
    tenant = @tenant
    archive_path = args[:archive_path]
    remap = args.fetch(:remap, true)
    dry_run = args.fetch(:dry_run, false)
    purge = args.fetch(:purge, false)
    do_restore = dry_run ? false : args.fetch(:restore, true)
    raise ArgumentError, "archive_path required" unless archive_path && File.exist?(archive_path)

    Rails.application.eager_load! unless Rails.application.config.eager_load

    work_dir = Rails.root.join("tmp", "restore_#{tenant.id}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}")
    FileUtils.mkdir_p(work_dir)

    system("tar -xzf #{archive_path} -C #{work_dir}") or raise "Failed to extract archive"

    # Find extracted label directory
    extracted_root = Dir.children(work_dir).map { |d| work_dir.join(d) }.find { |p| File.directory?(p) }
    raise "Could not determine extracted root" unless extracted_root

    dump_file = extracted_root.join("dump.jsonl")
    raise "dump.jsonl missing" unless File.exist?(dump_file)

    # Collect records grouped by model
    grouped = Hash.new { |h, k| h[k] = [] }
    original_tenant_id = nil
    File.foreach(dump_file) do |line|
      next if line.strip.empty?
      row = JSON.parse(line)
      model_name = row["model"]
      attrs = row["data"]
      original_tenant_id ||= attrs["tenant_id"] if attrs.is_a?(Hash) && attrs["tenant_id"]
      if remap && attrs.is_a?(Hash) && attrs["tenant_id"] && attrs["tenant_id"] != tenant.id
        attrs["tenant_id"] = tenant.id
      end
      grouped[model_name] << attrs
    end

    # Determine order (alphabetical usually fine) but put Team before User, and User before dependent records
    priority = %w[Tenant Team User Customer Project Product TimeMaterial PunchClock PunchCard Punch Setting Tag Task BackgroundJob Batch Calendar Event Invoice InvoiceItem ProvidedService Location Filter Dashboard Editor::Document Editor::Block]
    sorted_models = grouped.keys.sort_by { |m| [ priority.index(m) || 999, m ] }

    summary = []

    ActiveRecord::Base.transaction do

      if purge
        log_progress(summary, step: :purge_start)
        purge_plan = []
        sorted_models.each do |model_name|
          klass = safe_constantize(model_name)
          next unless klass && klass < ActiveRecord::Base && klass.column_names.include?("tenant_id")
          count_existing = klass.unscoped.where(tenant_id: tenant.id).count
          purge_plan << { model: model_name, existing: count_existing }
        end
        if dry_run
          purge_plan.each { |p| summary << { model: p[:model], planned_purge: p[:existing] } }
        else
          purge_plan.each do |p|
            klass = safe_constantize(p[:model])
            next unless klass
            deleted = 0
            klass.transaction do
              rel = klass.unscoped.where(tenant_id: tenant.id)
              deleted = rel.count
              rel.delete_all
            end
            summary << { model: p[:model], purged: deleted }
            log_progress(summary, step: :purged_model, model: p[:model], deleted: deleted)
          end
        end
        log_progress(summary, step: :purge_complete)
      end

      log_progress(summary, step: :restore_loop_start)
      sorted_models.each do |model_name|
        klass = safe_constantize(model_name)
        unless klass && klass < ActiveRecord::Base
          summary << { model: model_name, skipped: true, reason: "Unknown model" }
          log_progress(summary, step: :skipped_model, model: model_name)
          next
        end
        records = grouped[model_name]
        next if records.empty?
        pk = klass.primary_key
        inserted = 0
        updated = 0
        planned_inserted = 0
        planned_updated = 0
        records.each do |attrs|
          id = attrs[pk]
          target = id ? klass.unscoped.where(pk => id).first : nil
          if target
            target.assign_attributes(attrs)
            if target.changed?
              if dry_run || !do_restore
                planned_updated += 1
              else
                target.save!(validate: false)
                updated += 1
              end
            end
          else
            if dry_run || !do_restore
              planned_inserted += 1
            else
              klass.unscoped.insert(attrs) if klass.respond_to?(:insert)
              unless klass.unscoped.where(pk => id).exists?
                klass.unscoped.create!(attrs)
              end
              inserted += 1
            end
          end
        rescue => e
          summary << { model: model_name, error: e.message, id: attrs[pk] }
          log_progress(summary, step: :error, model: model_name, message: e.message)
        end
        summary << { model: model_name, inserted: inserted, updated: updated, total: records.size, planned_inserted: planned_inserted, planned_updated: planned_updated }
        log_progress(summary, step: :model_done, model: model_name, inserted: inserted, updated: updated, planned_inserted: planned_inserted, planned_updated: planned_updated)
      end
      log_progress(summary, step: :restore_loop_complete)

      unless dry_run || !do_restore
        restore_active_storage(extracted_root, tenant, remap, summary)
        log_progress(summary, step: :active_storage_restored)
      else
        summary << { model: "ActiveStorage", skipped: true, reason: "dry_run" } if dry_run
        log_progress(summary, step: :active_storage_skipped)
      end

    end # transaction

    TenantMailer.with(tenant: tenant, summary: summary, archive: archive_path.to_s).restore_completed.deliver_later unless args.fetch(:skip_email, false)
    summary

  rescue => e
    say "RestoreTenantJob failed: #{e.message}"
    UserMailer.error_report(e.full_message, "RestoreTenantJob#perform").deliver_later rescue nil
  end

  private

  def safe_constantize(name)
    name.constantize
  rescue NameError
    nil
  end

  def log_progress(summary, step:, **data)
    return unless @background_job
    payload = { step: step, at: Time.now.utc.iso8601 }.merge(data)
    begin
      current = JSON.parse(@background_job.job_progress || '{}') rescue {}
      current['log'] ||= []
      current['log'] << payload
      current['log'] = current['log'].last(200)
      current['summary'] = summary if summary.is_a?(Array)
      @background_job.update_column(:job_progress, current.to_json)
    rescue
    end
  end

  def restore_active_storage(root, tenant, remap, summary)
    attachments_file = root.join("active_storage_attachments.jsonl")
    blobs_file = root.join("active_storage_blobs.jsonl")
    return unless File.exist?(attachments_file) && File.exist?(blobs_file)

    # Blobs first
    blob_attrs = []
    File.foreach(blobs_file) do |line|
      next if line.strip.empty?
      blob_attrs << JSON.parse(line)
    end
    service = ActiveStorage::Blob.service if defined?(ActiveStorage::Blob)

    blob_inserted = 0
    blob_skipped = 0
    if defined?(ActiveStorage::Blob)
      blob_attrs.each do |attrs|
        begin
          id = attrs["id"]
          existing = ActiveStorage::Blob.unscoped.where(id: id).first
          if existing
            blob_skipped += 1
            next
          end
            # Ensure key not taken
            if ActiveStorage::Blob.where(key: attrs["key"]).exists?
              attrs["key"] = SecureRandom.hex(10) + attrs["key"]
            end
          ActiveStorage::Blob.unscoped.insert(attrs) if ActiveStorage::Blob.respond_to?(:insert)
          unless ActiveStorage::Blob.unscoped.where(id: id).exists?
            ActiveStorage::Blob.unscoped.create!(attrs)
          end
          blob_inserted += 1
          # Copy file
          if service && service.respond_to?(:path_for)
            src = root.join("blobs", attrs["key"][0, 2], attrs["key"][2, 2], attrs["key"][4, 2], attrs["key"])
            dest = service.path_for(attrs["key"]) rescue nil
            if src && File.exist?(src) && dest
              FileUtils.mkdir_p(File.dirname(dest))
              FileUtils.cp(src, dest) unless File.exist?(dest)
            end
          end
        rescue => e
          summary << { model: "ActiveStorage::Blob", error: e.message, id: attrs["id"] }
        end
      end
    end

    # Attachments
    attach_inserted = 0
    attach_skipped = 0
    if defined?(ActiveStorage::Attachment)
      File.foreach(attachments_file) do |line|
        next if line.strip.empty?
        attrs = JSON.parse(line)
        begin
          id = attrs["id"]
          if ActiveStorage::Attachment.unscoped.where(id: id).exists?
            attach_skipped += 1
            next
          end
          # ensure record exists (skip if not)
          record_type = attrs["record_type"]
          record_id = attrs["record_id"]
          rec_klass = safe_constantize(record_type)
          if rec_klass && rec_klass.unscoped.where(id: record_id).exists?
            ActiveStorage::Attachment.unscoped.insert(attrs) if ActiveStorage::Attachment.respond_to?(:insert)
            unless ActiveStorage::Attachment.unscoped.where(id: id).exists?
              ActiveStorage::Attachment.unscoped.create!(attrs)
            end
            attach_inserted += 1
          else
            summary << { model: "ActiveStorage::Attachment", skipped: true, reason: "Missing record", id: id }
          end
        rescue => e
          summary <<({ model: "ActiveStorage::Attachment", error: e.message, id: attrs["id"] })
        end
      end
    end

    summary << { model: "ActiveStorage::Blob", inserted: blob_inserted, skipped: blob_skipped, total: blob_attrs.size }
    summary << { model: "ActiveStorage::Attachment", inserted: attach_inserted, skipped: attach_skipped }
  end
end
