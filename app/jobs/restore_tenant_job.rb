class RestoreTenantJob < ApplicationJob
  queue_as :default

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
    extracted_root = Dir.children(work_dir).map { |d| work_dir.join(d) }.find { |p| File.directory?(p) }
    raise "Could not determine extracted root" unless extracted_root
    dump_file = extracted_root.join("dump.jsonl")
    raise "dump.jsonl missing" unless File.exist?(dump_file)

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

    priority = %w[Tenant Team User Customer Project Product TimeMaterial PunchClock PunchCard Punch Setting Tag Task BackgroundJob Batch Calendar Event Invoice InvoiceItem ProvidedService Location Filter Dashboard Editor::Document Editor::Block]
    model_names = grouped.keys

    if !purge && existing_tenant_data?(tenant, model_names)
      raise "Target tenant has existing data. Re-run with purge: true (PURGE=1) to allow restore."
    end

    sorted_models = dependency_order(model_names, priority)
    summary = []

    if dry_run
      integrity = validate_integrity(grouped, sorted_models)
      summary << { integrity: integrity }
      log_progress(summary, step: :integrity_validated, missing_parents: integrity[:missing_parent_refs].size, unknown_models: integrity[:unknown_models].size)
      return summary unless purge || do_restore # pure dry run no purge/restore requested
    end

    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute('PRAGMA defer_foreign_keys = ON') rescue nil

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
      fk_retry = Hash.new { |h, k| h[k] = [] }
      sorted_models.each do |model_name|
        process_model(grouped, model_name, tenant, dry_run, do_restore, summary, fk_retry)
      end
      if fk_retry.any?
        log_progress(summary, step: :retry_pass_start, models: fk_retry.keys)
        fk_retry.each do |model_name, recs|
          process_model({ model_name => recs }, model_name, tenant, dry_run, do_restore, summary, nil, retry_pass: true) unless recs.empty?
        end
        log_progress(summary, step: :retry_pass_complete)
      end
      log_progress(summary, step: :restore_loop_complete)

      unless dry_run || !do_restore
        restore_active_storage(extracted_root, tenant, remap, summary)
        log_progress(summary, step: :active_storage_restored)
      else
        summary << { model: "ActiveStorage", skipped: true, reason: "dry_run" } if dry_run
        log_progress(summary, step: :active_storage_skipped)
      end
    end

    TenantMailer.with(tenant: tenant, summary: summary, archive: archive_path.to_s).restore_completed.deliver_later unless args.fetch(:skip_email, false)
    summary
  rescue => e
    say "RestoreTenantJob failed: #{e.message}"
    UserMailer.error_report(e.full_message, "RestoreTenantJob#perform").deliver_later rescue nil
    raise
  end

  private

  def existing_tenant_data?(tenant, model_names)
    model_names.any? do |name|
      k = safe_constantize(name)
      k && k < ActiveRecord::Base && k.column_names.include?("tenant_id") && k.unscoped.where(tenant_id: tenant.id).limit(1).exists?
    end
  end

  def dependency_order(model_names, priority)
    models = model_names.map { |n| safe_constantize(n) }.compact
    table_for_model = models.to_h { |m| [m.table_name, m] }
    edges = Hash.new { |h, k| h[k] = [] }
    incoming = Hash.new(0)
    model_names.each { |n| incoming[n] = 0 }
    conn = ActiveRecord::Base.connection
    adapter = conn.adapter_name.downcase
    models.each do |m|
      table = m.table_name
      fks = []
      begin
        if adapter.include?("sqlite")
          conn.execute("PRAGMA foreign_key_list(#{table})").each do |row|
            fks << row[2] rescue nil
          end
        else
          conn.foreign_keys(table).each { |fk| fks << fk.to_table } if conn.respond_to?(:foreign_keys)
        end
      rescue
      end
      fks.compact.uniq.each do |parent_table|
        parent_model = table_for_model[parent_table]
        next unless parent_model
        child_name = m.name
        parent_name = parent_model.name
        unless edges[parent_name].include?(child_name)
          edges[parent_name] << child_name
          incoming[child_name] += 1
        end
      end
    end
    queue = incoming.select { |k, v| v == 0 && model_names.include?(k) }.keys
    order = []
    weight = lambda { |name| [priority.index(name) || 999, name] }
    queue.sort_by! { |n| weight.call(n) }
    until queue.empty?
      n = queue.shift
      order << n
      edges[n].each do |child|
        incoming[child] -= 1
        if incoming[child] == 0
          queue << child
          queue.sort_by! { |x| weight.call(x) }
        end
      end
    end
    remaining = (model_names - order)
    order + remaining.sort_by { |n| weight.call(n) }
  end

  def process_model(grouped, model_name, tenant, dry_run, do_restore, summary, fk_retry, retry_pass: false)
    klass = safe_constantize(model_name)
    unless klass && klass < ActiveRecord::Base
      summary << { model: model_name, skipped: true, reason: "Unknown model" }
      log_progress(summary, step: :skipped_model, model: model_name)
      return
    end
    records = grouped[model_name]
    return if records.empty?
    pk = klass.primary_key
    inserted = 0
    updated = 0
    planned_inserted = 0
    planned_updated = 0
    errors = 0
    records.each do |attrs|
      begin
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
            begin
              klass.unscoped.insert(attrs) if klass.respond_to?(:insert)
            rescue
            end
            unless id && klass.unscoped.where(pk => id).exists?
              rec = klass.unscoped.new(attrs)
              rec.save!(validate: false)
            end
            inserted += 1
          end
        end
      rescue => e
        if e.message =~ /FOREIGN KEY constraint failed/ && fk_retry && !retry_pass
          fk_retry[model_name] << attrs
        else
          summary << { model: model_name, error: e.message, id: attrs[pk] }
          log_progress(summary, step: :error, model: model_name, message: e.message)
        end
        errors += 1
      end
    end
    summary << { model: model_name, inserted: inserted, updated: updated, total: records.size, planned_inserted: planned_inserted, planned_updated: planned_updated, errors: errors, retry: fk_retry && fk_retry[model_name]&.size.to_i }
    log_progress(summary, step: retry_pass ? :model_retry_done : :model_done, model: model_name, inserted: inserted, updated: updated, planned_inserted: planned_inserted, planned_updated: planned_updated, errors: errors, retry: fk_retry && fk_retry[model_name]&.size.to_i)
  end

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

  def validate_integrity(grouped, sorted_models)
    require 'set'
    result = { missing_parent_refs: [], unknown_models: [], stats: {} }
    model_cache = {}
    sorted_models.each do |name|
      k = safe_constantize(name)
      if k.nil?
        result[:unknown_models] << name
        next
      end
      model_cache[name] = k
    end
    id_index = Hash.new { |h,k| h[k] = Set.new }
    grouped.each do |model_name, records|
      k = model_cache[model_name]
      next unless k
      pk = k.primary_key
      records.each do |attrs|
        id_index[model_name] << attrs[pk] if attrs[pk]
      end
    end
    grouped.each do |model_name, records|
      k = model_cache[model_name]
      next unless k
      records.each do |attrs|
        attrs.each do |key, val|
          next if key == "tenant_id"
          next unless key.end_with?("_id") && val
          assoc_name = key.sub(/_id\z/, "")
          candidates = [assoc_name.camelize, assoc_name.camelize.pluralize.singularize].uniq
          parent_model = candidates.map { |c| model_cache[c] || safe_constantize(c) }.compact.first
          next unless parent_model
          pm_name = parent_model.name
          unless id_index[pm_name].include?(val)
            result[:missing_parent_refs] << { child_model: model_name, parent_model: pm_name, fk: key, value: val }
          end
        end
      end
    end
    result[:stats][:models] = grouped.keys.size
    result[:stats][:records] = grouped.values.map(&:size).sum
    result
  end

  def restore_active_storage(root, tenant, remap, summary)
    attachments_file = root.join("active_storage_attachments.jsonl")
    blobs_file = root.join("active_storage_blobs.jsonl")
    return unless File.exist?(attachments_file) && File.exist?(blobs_file)
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
          if ActiveStorage::Blob.where(key: attrs["key"]).exists?
            attrs["key"] = SecureRandom.hex(10) + attrs["key"]
          end
          ActiveStorage::Blob.unscoped.insert(attrs) if ActiveStorage::Blob.respond_to?(:insert)
          unless ActiveStorage::Blob.unscoped.where(id: id).exists?
            ActiveStorage::Blob.unscoped.create!(attrs)
          end
          blob_inserted += 1
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

