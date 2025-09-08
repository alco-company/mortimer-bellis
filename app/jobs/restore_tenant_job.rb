class RestoreTenantJob < ApplicationJob
  queue_as :default

  #
  # tenant  = the tenant to restore data for
  # remap   = whether to remap ID's (backed up tenant ID not same as tenant to restore for)
  #
  def perform(**args)
    super(**args)
    @background_job = nil
    #
    # initialize variables
    tenant = @tenant
    archive_path = args[:archive_path]
    @args = args

    #
    # crucial checks
    raise ArgumentError, "archive_path required" unless archive_path && File.exist?(archive_path)
    raise ArgumentError, "tenant missing - ID required" unless tenant && tenant.id
    @dry_run = setting(:dry_run)
    #
    # prepare files
    summary = []
    base_dir = Rails.root.join("tmp")
    log_progress(summary, step: :initialize, tenant: @tenant, archive_path: archive_path, args: @args)
    Rails.application.eager_load! unless Rails.application.config.eager_load
    @restore_work_dir = base_dir.join("restore_#{tenant.id}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}")
    FileUtils.mkdir_p(@restore_work_dir)
    system("tar -xzf #{archive_path} -C #{@restore_work_dir}") or raise "Failed to extract archive"
    extracted_root = Dir.children(@restore_work_dir).map { |d| @restore_work_dir.join(d) }.find { |p| File.directory?(p) }
    raise "Could not determine extracted root" unless extracted_root
    log_progress(summary, step: :initialized, restore_work_dir: @restore_work_dir, extracted_root: extracted_root)
    #
    # extract metadata_file from the archive
    summary, metadata, manifest = extract_metadata_file(extracted_root, summary)
    log_progress(summary, step: :metadata_extracted, metadata: metadata, manifest: manifest)
    #
    # extract file_ids.jsonl from the archive
    summary, file_ids = extract_file_ids_file(extracted_root, summary, manifest)
    log_progress(summary, step: :file_ids_extracted, file_ids: file_ids)

    summary, collisions = data_values_collide(summary, file_ids)
    raise "Data collisions detected - cannot restore strict!" if collisions.include?(true) && setting(:strict)

    #
    # purge or remap existing tables/records
    summary, purges = purge_or_remap_records(summary, manifest, @restore_work_dir)
    log_progress(summary, step: :data_purged, purges: purges)
    return summary if purges.nil? && setting(:purge)
    return summary if !setting(:restore)
    #
    # restore data/records from archive
    summary, restores = restore_data_records(extracted_root, summary, file_ids)
    log_progress(summary, step: :data_restored, restores: restores)
    return summary if !setting(:remap)
    #
    # we need to sweep all tables looking for '-remap-' added during remapping
    summary, remaps = sweep_for_remaps(summary, restores)
    log_progress(summary, step: :remaps_swept, remaps: remaps)

    summary
  end

  private

    def setting(setting)
      case setting
      when :remap;              @args.fetch(:remap, true) && !setting(:dry_run)
      when :restore;            @args.fetch(:restore, true)
      when :allow_remap;        setting(:remap) && @args.fetch(:allow_remap, true) && ENV["RESTORE_NO_REMAP"] != "1"
      when :dry_run;            @args.fetch(:dry_run, false) || ENV["DRY_RUN"] == "1"
      when :purge;              @args.fetch(:purge, false) && !setting(:dry_run)
      when :strict;             @args.fetch(:strict, false)
      when :skip_models;        @args.fetch(:skip_models, "").to_s.split(",").map { |m| m.strip }.reject(&:blank?)
      when :debug_fk;           ENV["RESTORE_DEBUG_FK"].present? || @args.fetch(:debug_fk, false)
      when :no_tx;              ENV["RESTORE_NO_TX"].present? || @args.fetch(:no_tx, false)
      when :max_passes;         (ENV["RESTORE_MAX_PASSES"] || "5").to_i
      when :env_record_debug;   ENV["RESTORE_DEBUG_RECORDS"].present?
      end
    end

    def extract_metadata_file(extracted_root, summary)
      metadata_file = extracted_root.join("metadata.json")
      manifest = JSON.parse(File.read(extracted_root.join("manifest.json"))) rescue nil

      metadata = nil
      if File.exist?(metadata_file)
        begin
          require "digest"
          metadata = JSON.parse(File.read(metadata_file)) rescue nil
          dump_file = extracted_root.join("dump.jsonl")
          actual_sha = File.exist?(dump_file) ? Digest::SHA256.file(dump_file).hexdigest : nil
          expected_sha = metadata && metadata["record_dump_sha256"]
          verified = expected_sha && actual_sha && expected_sha == actual_sha
          summary << ({ metadata: { expected_sha256: expected_sha, actual_sha256: actual_sha, verified: verified }, manifest: manifest })
          raise "Metadata SHA256 mismatch" if setting(:strict) && !verified
        rescue => e
          summary << ({ metadata_error: e.message })
        end
      else
        summary << ({ metadata: { missing: true } })
        raise "metadata.json missing" if setting(:strict)
      end
      [ summary, metadata, manifest ]
    end

    # when we purge existing data records
    # we have two objectives
    # 1. remove all data for the tenant, including associated records, and ensure no orphaned records remain
    # 2. verify that no id's exist that collide with file_ids
    #
    def purge_or_remap_records(summary, manifest, dir)
      # Don't skip this step - we need to process even if we're not purging or remapping
      # Just return success indicator when nothing needs to be done
      unless setting(:purge) || setting(:remap)
        return [ summary, {} ] # return empty hash instead of true
      end

      seen_blob_ids = Set.new
      storage_root = dir.join("blobs")
      summary, collected_ids = collect_table_ids(summary, manifest, nil, nil)
      summary, remapped_ids = setting(:allow_remap) ?
        remap_table_ids(summary, collected_ids, seen_blob_ids, storage_root) :
        purge_records(summary, collected_ids)

      [ summary, remapped_ids ]

    rescue => e
      summary << ({ purge_records_error: e.message })
      log_progress(summary, step: :purge_records, message: e.message)
      [ summary, nil ]
    end

    def collect_table_ids(summary, manifest, seen_blob_ids, storage_root)
      table_ids = {}
      processed = 0
      manifest.each do |m|
        puts ""
        begin
          table = m["table"]
          print "Processing table: #{table}"
          next if setting(:skip_models).include?(table)
          next unless m["count"].is_a?(Integer) && m["count"] > 0

          klass = safe_constantize(table)
          table_ids[table] = klass.collect_ids(tenant_id: @tenant.id) if klass
          puts " - collected table IDs: #{table_ids[table]}"
          summary << { table: table, model: table.to_s, count: (table_ids[table]&.size || 0) }

          processed += table_ids[table]&.size if table_ids[table].is_a? Array
          log_progress(summary, step: :collect_table, table: table, processed: processed)

        rescue => e
          manifest << { table: table, model: m["table"], error: e.message }
          log_progress(summary, step: :error, table: table, message: e.message)
        end
      end
      log_progress(summary, step: :collect_table_done, table_ids_count: table_ids.size)
      [ summary, table_ids ]
    end

    # table_ids = [ { table: "users", ids: [1, 2, 3] }, ... ]
    # remapped_ids = {
    #   "users" => {
    #     "id" => { "1" => 4, "2" => 7, ... },
    #     "invited_by_id" => { "3" => 8, "4" => nil, ... }
    #   },
    # }
    def remap_table_ids(summary, table_ids, seen_blob_ids, storage_root)
      remapped_ids = {}
      unless setting(:strict)
        # Allow remapping of IDs for colliding records
        puts "Remapping table IDs...#{table_ids}"
        table_ids.each do |table, _ids|
          next if setting(:skip_models).include?(table)
          summary, remapped_ids = remap_table(summary, table_ids, table, remapped_ids)
        end
        summary, remapped_ids = purge_records(summary, table_ids) if setting(:purge) # purge after remap to clean up 'old' records
      end
      [ summary, remapped_ids ]
    end

    def remap_table(summary, table_ids, table, remapped_ids)
      remapped_ids[table] = { "id" => {} }
      klass = safe_constantize(table)
      unique_indexes = DependencyGraph.field_unique_indexes(table)
      klass.unscoped.where(id: table_ids[table]).each do |record|
        unless setting(:dry_run)
          summary, new_record, self_referencing = remap_record(summary, record.dup, record.id, table_ids, remapped_ids, unique_indexes)
          new_record.save(validate: false)
          new_record.update self_referencing => new_record.id if self_referencing
          if self_referencing
            puts "self_referencing: #{self_referencing}, old_id: #{record.id}, new_id: #{new_record.id}"
          end
          remapped_ids[table]["id"][record.id.to_s] = new_record.id
          puts "remapped #{table} #{record.id} to #{new_record.id}"
          summary << ({ table: table, old_id: record.id, new_id: new_record.id })
        else
          summary << ({ table: table, old_id: record.id, new_id: "-" })
        end
        log_progress(summary, step: :remap_progress)
      end
      [ summary, remapped_ids ]
    end

    #
    # remap fx users.tenant_id from 1 -> 402
    # or batches.user_id from 3 -> 6
    # or settings.setable_type = "TimeMaterial", settings.setable_id = 5 -> 12
    #
    def remap_record(summary, record, record_id, table_ids, remapped_ids, unique_indexes = [])
      table = record.class.table_name
      foreign_keys, polymorphic_keys = foreign_polymorphic_keys(table)
      self_referencing = nil
      puts "Remapping foreign keys for #{table}/#{record_id} with #{foreign_keys.inspect} and #{polymorphic_keys.inspect}"
      print "----------"
      begin
        if unique_indexes.any?
          print "i: "
          # remap unique fields
          unique_indexes.each do |field|
            if record.respond_to?(field)
              record[field] = record[field] + "-remap-#{SecureRandom.hex(4)}" unless record[field].nil?
              print "."
            end
          end
        end
      rescue => e
         summary << { table: table, error: e.message }
         log_progress(summary, step: :remap_index_error, table: table, message: e.message)
         print "e"
      end
      puts " "
      begin
        # remap foreign keys - user_id
        foreign_keys.each do |fk|
          # is association possible currently?
          next if setting(:skip_models).include?(fk[:table])
          if table_ids[fk[:table]]
            print "fk: #{fk[:table]} #{ remapped_ids[fk[:table]] }"
            summary, remapped_ids = remap_table(summary, table_ids, fk[:table], remapped_ids) if !remapped_ids[fk[:table]]
            raise "no remapped table found" unless remapped_ids[fk[:table]]

            # does association exist currently?
            # table_ids["tenants"] = [1, 2, 3]
            if record.respond_to?(fk[:key]) && table_ids[fk[:table]].include?(record[fk[:key]])
              # has association been remapped?
              # remapped_ids["tenants"] = { "id" => { "1" => "10", "2" => "20", "3" => "30" } }
              raise "initialization error - should not happen" unless remapped_ids[fk[:table]]["id"]

              # possibly remap self-referential foreign keys (like parent_id)
              if fk[:table] == table && record[fk[:key]].to_s == record_id.to_s
                self_referencing = fk[:key]
                puts "self-referencing #{self_referencing} for #{table}/#{record_id}"
              end
              if remapped_ids[fk[:table]]["id"].keys.include?(record[fk[:key]].to_s)
                puts " #{fk[:key]}= #{record[fk[:key]]} -> #{ remapped_ids[fk[:table]]["id"][record[fk[:key]].to_s] }"
                record[fk[:key]] = remapped_ids[fk[:table]]["id"][record[fk[:key]].to_s]
                self_referencing = nil
              end
            end
          end
        end
        puts " "
      rescue => e
         summary << { table: table, error: e.message }
         log_progress(summary, step: :remap_foreign_key_error, table: table, message: e.message)
         print "e"
      end
      puts " "
      begin
        #
        # remap polymorphic foreign keys
        polymorphic_keys.each do |pk|
          klass = safe_constantize(record["#{pk}_type"])
          if klass && table_ids[klass.table_name]
            puts "Remapping polymorphic keys for #{table} record #{record["#{pk}_type"]}/#{record["#{pk}_id"]}"
            next if setting(:skip_models).include?(klass.table_name)
            print "Remapping polymorphic key #{pk} for #{table} record #{record.id} "
            summary, remapped_ids = remap_table(summary, table_ids, klass.table_name, remapped_ids) unless remapped_ids[klass.table_name]
            raise "no remapped table found" unless remapped_ids[klass.table_name]
            # does association exist currently?
            if record.respond_to?("#{pk}_id") && table_ids[klass.table_name].include?(record["#{pk}_id"])
              print ", found #{ table_ids[klass.table_name].include?(record["#{pk}_id"]) }"
              # has association been remapped?
              raise "initialization error - should not happen" unless remapped_ids[klass.table_name]["id"]
              begin
                if remapped_ids[klass.table_name]["id"].keys.include?(record["#{pk}_id"].to_s)
                  record["#{pk}_id"] = remapped_ids[klass.table_name]["id"][record["#{pk}_id"].to_s]
                  puts ", remapped #{record["#{pk}_id"]} to #{ remapped_ids[klass.table_name]["id"][record["#{pk}_id"].to_s] }"
                end
              rescue => e
                summary << { table: table, field: pk, record_id: record.id, error: e.message }
                log_progress(summary, step: :remap_polymorphic_key_error, table: table, message: e.message)
                puts ", remapping failed: #{e.message}"
              end
            end
          end
        end
      rescue => e
         summary << { table: table, error: e.message }
         log_progress(summary, step: :remap_polymorphic_key_error, table: table, message: e.message)
         puts "Error - #{e.message}"
      end
      summary << { table: table, foreign_keys: foreign_keys, polymorphic_keys: polymorphic_keys }

      [ summary, record, self_referencing ]
    end

    def foreign_polymorphic_keys(table)
      foreign_keys = [ { table: "tenants", key: "tenant_id" } ]
      polymorphic_keys = []

      case table
      when "tenants";           foreign_keys = []
      when "users";             foreign_keys += [ { table: "teams", key: "team_id" }, { table: "users", key: "invited_by_id" } ]
      # default foreign_keys/polymorphic_keys
      # when "teams"
      # when "calls"
      # when "customers"
      # when "dashboards"
      # when "editor_documents"
      # when "locations"
      # when "products"
      when "editor_blocks";     foreign_keys =  [ { table: "editor_documents", key: "document_id" }, { table: "editor_blocks", key: "parent_id" } ]
      when "projects";          foreign_keys += [ { table: "customers", key: "customer_id" } ]
      when "invoices";          foreign_keys += [ { table: "customers", key: "customer_id" }, { table: "projects", key: "project_id" } ]
      when "invoice_items";     foreign_keys += [ { table: "invoices", key: "invoice_id" }, { table: "projects", key: "project_id" }, { table: "products", key: "product_id" }  ]
      when "punch_card";        foreign_keys += [ { table: "users", key: "user_id" } ]
      when "punch_clocks";      foreign_keys += [ { table: "locations", key: "location_id" } ]
      when "punches";           foreign_keys += [ { table: "users", key: "user_id" }, { table: "punch_clocks", key: "punch_clock_id" } ]
      when "background_jobs";   foreign_keys += [ { table: "users", key: "user_id" } ]
      when "batches";           foreign_keys += [ { table: "users", key: "user_id" } ]
      when "filters";           foreign_keys += [ { table: "users", key: "user_id" } ]
      when "sessions";          foreign_keys =  [ { table: "users", key: "user_id" } ]
      when "time_materials";    foreign_keys += [ { table: "customers", key: "customer_id" }, { table: "projects", key: "project_id" }, { table: "products", key: "product_id" }, { table: "users", key: "user_id" } ]
      when "tasks";             polymorphic_keys = [ "tasked_for" ]
      when "calendars";         polymorphic_keys = [ "calendarable" ]
      when "provided_services"; foreign_keys += [ { table: "users", key: "authorized_by_id" } ]
      when "tags";              foreign_keys += [ { table: "users", key: "user_id" } ]
      when "taggings";          foreign_keys = [ { table: "tags", key: "tag_id" } ]; polymorphic_keys = [ "taggable" ]
      when "settings";          polymorphic_keys = [ "setable" ]
      end
      [ foreign_keys, polymorphic_keys ]
    end

    def purge_records(summary, table_ids)
      DependencyGraph.purge_order.each do |table|
        next unless table_ids[table]
        next if setting(:skip_models).include?(table)
        begin
          klass = safe_constantize(table)
          print "Purging records for #{table}: #{table_ids[table]}"
          if klass and !setting(:dry_run)
            klass.unscoped.where(id: table_ids[table]).any? ?
              klass.unscoped.where(id: table_ids[table]).delete_all :
              puts("-- no records found") && summary << ({ table: table, message: "no records purged - none found" })
          end
          puts "-- done"
        rescue => e
          summary << ({ table: table, purge_records_error: e.message })
          log_progress(summary, step: :purge_records, message: e.message)
          puts "-- failed: #{e.message}"
        end
        log_progress(summary, step: :purge_records, table: table, ids: table_ids[table])
      end
      log_progress(summary, step: :purge_records, done: true)
      [ summary, table_ids ]
    end

    def extract_file_ids_file(extracted_root, summary, manifest)
      file_ids_path = extracted_root.join("file_ids.jsonl")
      unless File.exist?(file_ids_path)
        puts "file_ids.jsonl missing - trying to get ids from dump!"
        # Try to extract file IDs from the dump
        dump_file = extracted_root.join("dump.jsonl")
        if File.exist?(dump_file)
          file_ids = {}
          File.foreach(dump_file) do |line|
            row = JSON.parse(line)
            next if setting(:skip_models).include?(row["model"])
            table_name = safe_table_name(row["model"])
            attrs = row["data"]
            file_ids[table_name] ||= []
            file_ids[table_name] << attrs["id"]
          end
          ids = file_ids
        else
          raise "dump.jsonl missing too!"
        end
      else
        begin
          ids = {}
          manifested_tables = manifest.filter { |t| t["table"] if t.keys.include? :count } rescue []
          file_ids_json = File.read(file_ids_path)
          file_ids = JSON.parse(file_ids_json)
          manifested_tables.each do |table|
            next if setting(:skip_models).include?(table)
            ids[table] = file_ids[table] ||= []
          end
          summary << ({ file_ids_path: file_ids_path, file_tables: ids.keys })
        rescue => e
          summary << ({ file_ids_error: e.message })
        end
      end

      [ summary, ids ]
    end

    def restore_data_records(extracted_root, summary, file_ids)
      restores = {}
      remapped_ids = {}
      begin
        restorable_records = read_dump_file(extracted_root)
        puts "Restoring data records...#{restorable_records.keys}"
        DependencyGraph.restore_order.each do |table|
          restores[table] = []
          begin
            remapped_ids[table] ||= { "id" => {} }
            klass = safe_constantize(table)
            raise "#{table} model not found when preparing to restore data records" unless klass
            restorable_records[table].each do |attrs|
              puts "Restoring record for #{table} with attrs: #{attrs.inspect}"
              if setting(:strict) || (!setting(:purge) && !setting(:remap))
                record = klass.find_by(id: attrs["id"]) || raise("Record not found - cannot restore :strict!")
                record.update(attrs) unless setting(:dry_run)
                remapped_ids[record.class.table_name]["id"][record.id.to_s] = record.id.to_s
              else
                record = klass.new attrs
                summary, record = klass.restore(summary, extracted_root, record, remapped_ids)
              end
              # summary, record = remap_record(summary, record, file_ids, remapped_ids, false) if setting(:allow_remap) && !setting(:strict)
              if klass && !setting(:dry_run)
                # record.save!(validate: false)
                restores[table] << { id: record["id"], record: record }
                # remapped_ids[table]["id"][attrs["id"]] = record.id
                summary << ({ restored: { model: table, from: { id: attrs["id"], attrs: attrs }, to: { id: record.id, attrs: record.attributes } } })
                log_progress(summary, step: :restored_data_record, model: table, id: record.id)
              else
                summary << ({ restored: { model: table, id: record["id"], attrs: record } }) if setting(:dry_run)
                log_progress(summary, step: :restore_data_record)
              end
              # remapped_ids[table][attrs["id"]] = record
            end
          rescue => e
            summary << ({ restore_data_records_error: e.message })
            log_progress(summary, step: :restore_data_records, message: e.message)
          end
        end
      rescue => e
        summary << ({ dump_file: dump_file, file_ids: file_ids })
        log_progress(summary, step: :restore_data_records, message: e.message)
      end
      [ summary, restores ]
    end

    def read_dump_file(extracted_root)
      dump_file = extracted_root.join("dump.jsonl")
      raise "dump.jsonl missing" unless File.exist?(dump_file)
      restorable_records = {}
      File.foreach(dump_file) do |line|
        row = JSON.parse(line)
        next if setting(:skip_models).include?(row["model"])
        table_name = safe_table_name(row["model"])
        attrs = row["data"]
        restorable_records[table_name] ||= []
        restorable_records[table_name] << attrs
      end
      restorable_records
    end

    def data_values_collide(summary, file_ids)
      collisions = {}
      file_ids.each do |table, ids|
        next if setting(:skip_models).include?(table)
        begin
          collisions[table] = safe_constantize(table).where(id: ids).any?
        rescue => e
          summary << ({ table: table, ids: ids, data_values_collide_error: e.message })
        end
      end
      [ summary, collisions ]
    end

    # restores[table] << { id: record["id"], record: record }
    def sweep_for_remaps(summary, restores)
      remaps = {}
      summary << { step: :sweep_for_remaps }
      restores.keys.each do |table|
        klass = safe_constantize(table)
        records = restores[table]
        records.each do |record|
          next unless record[:record].is_a?(Hash)
          record[:record].each do |field, value|
            begin
              if value.is_a?(String) && value.include?("-remap-")
                cleaned_value = value.gsub(/-remap-.*$/, "")
                klass.find(record[:id]).update(field => cleaned_value)
                remaps[table] ||= []
                remaps[table] << { id: record[:id], field: field, value: value }
              end
              summary << ({ table: table, id: record[:id], field: field, value: value, cleaned_value: cleaned_value })
            rescue => e
              summary << ({ table: table, id: record[:id], field: field, value: value, remap_error: e.message })
            end
          end
        end
        log_progress(summary, step: :sweep_for_remaps, message: "Completed remapping for #{table}")
      end
      [ summary, remaps ]
    end

    #
    # "tenants" => Tenant
    #
    def safe_constantize(name)
      case name
      when "editor_documents";  Editor::Document
      when "editor_blocks";     Editor::Block
      else;                     name.classify.constantize
      end
    rescue NameError
      nil
    end

    def safe_table_name(name)
      case name
      when "editor_documents";  "editor_documents"
      when "editor_blocks";     "editor_blocks"
      else;                     name.underscore.pluralize
      end
    end
end
