# frozen_string_literal: true

# module ExportPdf
module Persistence
  extend ActiveSupport::Concern

  included do
    #
    # afford ActiveStorage attachments backup
    def backup_active_storage_attachments(fa, fb, seen_blob_ids, storage_root)
      attachments = all_attachments
      return if attachments.empty?

      summary = { copied: 0, skipped: 0, missing_blobs: 0, errors: [] }

      service = ActiveStorage::Blob.service if defined?(ActiveStorage::Blob)
      unless service
        summary[:errors] << { step: :active_storage_copy_error, message: "ActiveStorage service not available" }
        return summary
      end

      attachments.each do |att|
        begin
          fa.puts(att.attributes.to_json) unless fa.nil?
        rescue => e
          summary[:errors] << { step: :active_storage_copy_error, att_attributes: att.attributes.to_json, message: e.message }
        end

        blob = att.blob
        unless blob
          summary[:missing_blobs] += 1
          next
        end
        if seen_blob_ids.include?(blob.id)
          summary[:skipped] += 1
          next
        end

        begin
          fb.puts(blob.attributes.to_json) unless fb.nil?
          seen_blob_ids << blob.id
          #
          # Copy binary file if local disk & path available
          summary = store_blob(blob, service, storage_root, summary) if service&.respond_to?(:path_for) && !storage_root.nil?
        rescue => e
          summary[:errors] << { step: :active_storage_copy_error, blob_attributes: blob&.attributes&.to_json, message: e.message }
          next
        end
      end
      summary
    end

    def store_blob(blob, service, storage_root, summary)
      begin
        src = service.path_for(blob.key)
        if File.exist?(src)
          dest_dir = storage_root.join(blob.key[0, 2], blob.key[2, 2], blob.key[4, 2])
          FileUtils.mkdir_p(dest_dir)
          FileUtils.cp(src, dest_dir.join(blob.key))
        end
        summary[:copied] += 1
      rescue => e
        summary[:errors] << { step: :active_storage_copy_error, blob_id: blob.id, message: e.message }
      end
      summary
    end

    # Collect all attachments for the record
    def all_attachments
      self.class.reflect_on_all_attachments.flat_map do |ref|
        att = public_send(ref.name)
        if att.respond_to?(:attachments) # has_many_attached
          att.attachments
        else
          [ att.attachment ].compact       # has_one_attached
        end
      end
    end

    # Backup taggings for the record
    def backup_taggings(f)
      return unless respond_to?(:taggings)

      count = 0
      taggings.each do |tagging|
        f.puts({ model: "taggings", data: tagging.attributes }.to_json) unless f.nil?
        count += 1
      end
      { step: :backup_taggings, record: "#{self.class.table_name}, #{id}", taggings_count: count }
    rescue => e
      Rails.logger.error("Error backing up taggings for #{self.class.table_name}, #{id}: #{e.message}")
      { step: :backup_taggings_error, record: "#{self.class.table_name}, #{id}", taggings_count: count, error: e.message }
    end
  end

  class_methods do
    # scope for tenant-specific queries
    # override on models that have a tenant association other than tenant_id
    def scoped_for_tenant(tenant_id)
      mortimer_scoped(tenant_id)
    end

    def collect_ids(tenant_id: nil)
      ids = []
      return ids if tenant_id.nil?

      scoped_for_tenant(tenant_id).find_in_batches(batch_size: 1000) do |batch|
        ids.concat(batch.map(&:id))
      end
      ids
    end

    #
    def backup(f: nil, fa: nil, fb: nil, seen_blob_ids: nil, storage_root: nil, tenant_id: nil)
      count = scoped_for_tenant(tenant_id).count
      processed = 0
      return 0 if count == 0

      summary = []
      table_ids = []
      scoped_for_tenant(tenant_id).find_in_batches(batch_size: 500) do |batch|
        batch.each do |rec|
          table_ids << rec.id
          f.puts({ model: table_name, data: rec.attributes }.to_json) unless f.nil?
          summary << rec.backup_active_storage_attachments(fa, fb, seen_blob_ids, storage_root) unless fa.nil? || fb.nil?
          summary << rec.backup_taggings(f)
        end
        processed += batch.size
        summary << { processed: processed, total: count }
      end
      summary << { processed: processed, total: count, table_ids: table_ids }
      [ processed, table_ids, summary ]
    end

    #
    # remove all attachments
    # remove all polymorphic associations
    # remove all records belonging to this record
    # remove this record
    #
    def purge
    end


    #
    # restore this record - check if records that this record belongs_to have been restored/remapped
    # restore all attachments
    # restore all polymorphic associations
    # restore all records belonging to this record
    #
    # - remap if necessary and !strict
    #
    def restore(summary, extracted_root, record, remapped_ids, dry_run = false)
      results = []

      record.class.reflections.values.select(&:belongs_to?).each do |reflection|
        summary, record, result, _msg = check_association(summary, record, reflection, remapped_ids)
        results << result
      end
      # Save the record even if association checks had errors - dependencies are restored in order
      # so associations will be available when needed
      begin
        old_id = record.id
        # Get original ID from backup for attachment restoration (may differ from old_id if remapped)
        original_backup_id = record.instance_variable_get(:@_original_backup_id) || old_id
        remapped_ids[record.class.table_name] ||= { "id" => {} }
        record.save(validate: false) unless dry_run
        remapped_ids[record.class.table_name]["id"][old_id.to_s] = record.id.to_s unless old_id.nil?
        #
        # restore attachments using original backup ID to match attachment records
        restore_attachments(summary, record, extracted_root, original_backup_id)
      rescue => e
        summary << ({ step: :restore_record, record: "#{record.class.table_name}, #{record.id}", error: e.message, backtrace: e.backtrace.first(3) })
      end

      [ summary, record ]
    end    #
    # remapped_ids["tenants"] = { "id" => { "2" => "3" } }
    #
    def check_association(summary, record, reflection, remapped_ids)
      tbl = reflection.foreign_type ? safe_constantize(record[reflection.foreign_type])&.table_name : reflection.plural_name
      fk = reflection.foreign_key
      summary << ({ step: :check_association, record: "#{record.class.table_name}, #{record.id}", association: tbl, foreign_key: fk, foreign_key_value: record[fk].to_s })
      rid = remapped_ids[tbl]["id"][record[fk].to_s] rescue nil
      if reflection.foreign_type
        raise "Orphaned Polymorphic Association discovered" if record[reflection.foreign_type].nil? && !record[fk].nil?
        #
        # polymorphic association believed to be remapped
        if rid && record[reflection.foreign_type] && record[fk]
          _ = safe_constantize(record[reflection.foreign_type]).unscoped.find(rid)
          record[fk] = rid.to_i
        end
      else
        raise "ID missing" if rid.nil?
        _ = reflection.klass.unscoped.find(rid)
        record[fk] = rid.to_i
      end
      summary << ({ step: :check_association_done, record: "#{record.class.table_name}, #{record.id}", association: tbl, foreign_key: fk, remapped_foreign_key_value: record[fk].to_s })
      [ summary, record, :success, tbl ]

    rescue ActiveRecord::RecordNotFound => e
      # believed to be remapped but not the case!
      summary << ({ step: :restore_check_association, record: "#{record.class.table_name}, #{record.id}", association: tbl, foreign_key: fk, foreign_key_value: record[fk].to_s, error: e.message })
      [ summary, record, :error, e.message ]

    rescue => e
      # not remapped (yet)
      summary << ({ step: :restore_check_association, record: "#{record.class.table_name}, #{record.id}", association: tbl, error: e.message })
      [ summary, record, :error, e.message ]
    end

    def restore_attachments(summary, record, extracted_root, old_id)
      return [] unless defined?(ActiveStorage::Blob) && record.class.reflect_on_all_attachments.any?

      att_file = extracted_root.join("active_storage_attachments.jsonl")
      service  = ActiveStorage::Blob.service
      summary << ({ step: :restore_attachments, record: "#{record.class.table_name}, #{record.id}", dry_run: @dry_run, att_file: att_file })

      File.foreach(att_file) do |line|
        next if line.strip.empty?
        attrs = JSON.parse(line)
        record_type = attrs["record_type"]
        next if record_type != record.class.to_s
        record_id   = attrs["record_id"]
        next if record_id.to_s != old_id.to_s
        name        = attrs["name"]
        blob_id     = attrs["blob_id"]

        summary, blob = restore_blob(summary, service, extracted_root, blob_id)

        # Deduplicate (one attachment with same name + blob on same record)
        duplicate = ActiveStorage::Attachment.find_by(
          record_type: record_type,
          record_id:   record_id,
          name:        name,
          blob_id:     blob.id
        )
        if duplicate
          duplicate.update record_id: record.id unless @dry_run
          summary << ({ step: :restore_attachments, record: "#{record.class.table_name}, #{record.id}", dry_run: @dry_run, duplicate_att: duplicate.id, blob: blob.id })
          next
        end

        next if @dry_run
        att = ActiveStorage::Attachment.create!(
          name: name,
          record_type: record_type,
          record_id: record.id,
          blob_id: blob.id
        )
        summary << ({ step: :restore_attachments, record: "#{record.class.table_name}, #{record.id}", dry_run: @dry_run, att: att.id, blob: blob.id })
      rescue => e
        say "Attachment restore error (#{record_type}##{record_id} #{name}): #{e.message}"
      end
      summary
    end

    def restore_blob(summary, service, extracted_root, blob_id)
      blob_file  = extracted_root.join("active_storage_blobs.jsonl")
      summary << ({ step: :restore_blobs, blob_id: blob_id, dry_run: @dry_run, blob_file: blob_file })

      File.foreach(blob_file) do |line|
        next if line.strip.empty?
        attrs = JSON.parse(line)
        next if attrs["id"].to_s != blob_id.to_s
        key = attrs["key"]
        # Prefer existing by key (id can differ in target system)
        existing = ActiveStorage::Blob.find_by(key: key)
        if existing
          copy_blob_file(service, extracted_root, existing.key)
          summary << ({ step: :restore_blobs, key: key, blob_id: existing.id, message: "exists!" })
          return [ summary, existing ]
        end

        blob = ActiveStorage::Blob.new(
          key:         key,
          filename:    attrs["filename"],
          content_type: attrs["content_type"],
          metadata:    attrs["metadata"],
          byte_size:   attrs["byte_size"],
          checksum:    attrs["checksum"],
          service_name: attrs["service_name"] || ActiveStorage::Blob.service.name
        )
        # Allow preserving original id if you really want (optional):
        # blob.id = attrs["id"] if attrs["id"]

        if @dry_run
          summary << ({ step: :restore_blob, key: key, blob_id: blob.id, message: "new!" })
          copy_blob_file(service, extracted_root, key) # just check existence
          return [ summary, blob ]
        end

        blob.save(validate: false)
        copy_blob_file(service, extracted_root, key)
        return [ summary, blob ]

      rescue => e
        say "Blob restore error (key=#{key}): #{e.message}"
        return nil
      end
    end

    def copy_blob_file(service, extracted_root, key)
      files_root = extracted_root.join("blobs")
      # Only relevant for disk service with path_for
      return unless service.respond_to?(:path_for)
      src = files_root.join(key[0, 2], key[2, 2], key[4, 2], key)
      return unless src.exist?
      dest = service.path_for(key)
      return if File.exist?(dest) # Already present
      unless @dry_run
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)
      end
    end

    def safe_constantize(name)
      case name
      when "editor_documents";  Editor::Document
      when "editor_blocks";     Editor::Block
      else;                     name.classify.constantize
      end
    rescue NameError
      nil
    end
  end
end
