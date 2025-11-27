class BackupTenantJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    tenant = @tenant
    return unless tenant

    summary = []
    log_progress(summary, step: :start)

    Rails.application.eager_load! unless Rails.application.config.eager_load

    # Setup working directory and backup files
    timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
    label = "tenant_#{tenant.id}_#{timestamp}"
    # Use storage directory instead of tmp - tmp is not persisted in Docker volumes
    base_dir = Rails.root.join("storage", "tenant_backups", label)
    FileUtils.mkdir_p(base_dir)

    manifest = []
    summary << ({ timestamp: timestamp, label: label, base_dir: base_dir })
    log_progress(summary, step: :scan_tables)

    # - part of Rails
    models_by_table = {}
    ActiveRecord::Base.descendants.each do |m|
      next unless m.respond_to?(:table_name)
      models_by_table[m.table_name] = m
    end

    tenant_tables = DependencyGraph.backup_order
    raise "No tenant tables found" if tenant_tables.empty?

    dump_path = base_dir.join("dump.jsonl")
    file_ids_path = base_dir.join("file_ids.jsonl")
    attachments_path = base_dir.join("active_storage_attachments.jsonl")
    blobs_path       = base_dir.join("active_storage_blobs.jsonl")
    storage_root     = base_dir.join("blobs")
    seen_blob_ids = Set.new
    FileUtils.mkdir_p(storage_root)

    summary << ({ dump_path: dump_path, attachments_path: attachments_path, blobs_path: blobs_path, storage_root: storage_root })
    log_progress(summary, step: :paths_created)

    processed = 0
    table_ids = {}
    File.open(dump_path, "w") do |f|
      File.open(attachments_path, "w") do |fa|
        File.open(blobs_path, "w") do |fb|
          tenant_tables.each do |table|
            begin
              model = models_by_table[table]
              count, table_ids[table], result = model.backup(f: f, fa: fa, fb: fb, seen_blob_ids: seen_blob_ids, storage_root: storage_root, tenant_id: tenant.id) if model
              next if count == 0
              processed += count
              manifest << ({ table: table, model: table.to_s, count: count })
              log_progress(summary, step: :dump_progress, table: table, processed: processed, result: result)

            rescue => e
              manifest << { table: table, model: (model&.name), error: e.message }
              log_progress(summary, step: :error, table: table, message: e.message)
            end
          end
        end
      end
    end

    File.write(file_ids_path, JSON.pretty_generate(table_ids))
    log_progress(summary, step: :file_ids_written)

    File.write(base_dir.join("manifest.json"), JSON.pretty_generate(manifest))
    log_progress(summary, step: :manifest_written, entries: manifest.size)

    begin
      require "digest"
      dump_file = base_dir.join("dump.jsonl")
      dump_sha256 = File.exist?(dump_file) ? Digest::SHA256.file(dump_file).hexdigest : nil
      attachments_count = 0
      attach_list_file = base_dir.join("active_storage_attachments.jsonl")
      attachments_count = File.foreach(attach_list_file).count rescue 0 if File.exist?(attach_list_file)
      git_sha = `git rev-parse HEAD`.strip rescue nil
      metadata = {
        schema_version: (ActiveRecord::Migrator.current_version rescue nil),
        app_sha: git_sha,
        created_at: Time.now.utc.iso8601,
        tenant_id: tenant.id,
        manifest_entries: manifest.size,
        record_dump_sha256: dump_sha256,
        active_storage_attachments_count: attachments_count
      }
      File.write(base_dir.join("metadata.json"), JSON.pretty_generate(metadata))
      summary << ({ dump_file: dump_file, dump_sha256: dump_sha256, attachments_count: attachments_count, git_sha: git_sha })
      log_progress(summary, step: :metadata_written)
    rescue => e
      log_progress(summary, step: :metadata_error, message: e.message)
    end

    archive_path = Rails.root.join("storage", "tenant_backups", "#{label}.tar.gz").to_s
    begin
      Dir.chdir(base_dir.dirname)
      success = system("tar", "-czf", archive_path, label)
      unless success
        raise "tar command failed with exit code #{$?.exitstatus}"
      end
    ensure
      Dir.chdir(Rails.root)
    end
    log_progress(summary, step: :archive_created, path: archive_path)

    begin
      # Generate a proper download URL instead of file path
      filename = File.basename(archive_path)
      download_url = Rails.application.routes.url_helpers.tenant_backup_download_url(filename: filename, host: ENV["WEB_HOST"] || "localhost:3000", protocol: "https")
      pdf_report_path = archive_path.to_s.gsub(/\.tar\.gz$/, "_report.pdf")
      Rails.logger.info "BackupTenantJob: Checking for PDF report at #{pdf_report_path}"
      pdf_report_url = nil
      if File.exist?(pdf_report_path)
        pdf_report_url = Rails.application.routes.url_helpers.tenant_backup_download_url(filename: File.basename(pdf_report_path), host: ENV["WEB_HOST"] || "localhost:3000", protocol: "https")
        Rails.logger.info "BackupTenantJob: PDF report found, url set to #{pdf_report_url}"
      else
        Rails.logger.warn "BackupTenantJob: PDF report not found at #{pdf_report_path}, no URL will be set"
      end
      # Generate PDF report and store it
      generate_backup_report_pdf(tenant, summary, archive_path)

      # Now set up PDF link for email
      pdf_report_path = archive_path.to_s.gsub(/\.tar\.gz$/, "_report.pdf")
      Rails.logger.info "BackupTenantJob: Checking for PDF report at #{pdf_report_path}"
      pdf_report_url = nil
      if File.exist?(pdf_report_path)
        pdf_report_url = Rails.application.routes.url_helpers.tenant_backup_download_url(filename: File.basename(pdf_report_path), host: ENV["WEB_HOST"] || "localhost:3000", protocol: "https")
        Rails.logger.info "BackupTenantJob: PDF report found, url set to #{pdf_report_url}"
      else
        Rails.logger.warn "BackupTenantJob: PDF report not found at #{pdf_report_path}, no URL will be set"
      end

      TenantMailer.with(tenant: tenant, link: download_url, pdf_report_url: pdf_report_url).backup_created.deliver_later
      log_progress(summary, step: :email_enqueued, download_url: download_url)
      @background_job.update_column :job_progress, { step: :completed, completed_at: Time.now.utc.iso8601, download_url: download_url, pdf_report_url: pdf_report_url }.to_json

      # Cleanup: Remove temporary directory after successful archive creation and email queuing
      FileUtils.rm_rf(base_dir)
      # log_progress(summary, step: :cleanup_completed, removed: base_dir.to_s)

      # Remove old backups (8+ days old) for this tenant
      cleanup_old_backups(tenant)
    rescue => e
      say "BackupTenantJob email failed: #{e.message}"
      log_progress(summary, step: :error, phase: :email, message: e.message)
    end

    archive_path
  rescue => e
    say "BackupTenantJob failed: #{e.message}"
    log_progress(summary, step: :failed, message: e.message)
    UserMailer.error_report(e.full_message, "BackupTenantJob#perform").deliver_later rescue nil
  end

  private

    def generate_backup_report_pdf(tenant, summary, archive_path)
      return unless @background_job

      begin
        # Create HTML report
        html_content = generate_backup_html_report(tenant, summary, archive_path)

        # Save HTML temporarily
        html_path = Rails.root.join("tmp", "backup_report_#{tenant.id}_#{Time.now.to_i}.html")
        File.write(html_path, html_content)

        # Generate PDF path (same location as tar.gz)
        pdf_path = archive_path.to_s.gsub(/\.tar\.gz$/, "_report.pdf")

        # Build PDF using external service (internal service, uses HTTP)
        pdf_host = ENV["PDF_HOST"] || "localhost"
        # Extract hostname (remove any existing port) and always use port 8080 for PDF service
        hostname = pdf_host.split(":").first
        url = "http://#{hostname}:8080"
        options = {
          headers: { "ContentType" => "multipart/form-data" },
          body: { html: File.open(html_path) }
        }
        response = HTTParty.post(url, options)

        # Check response status
        unless response.success?
          raise "PDF service returned status #{response.code}: #{response.body}"
        end

        # Write response body (binary PDF data)
        File.open(pdf_path, "wb") do |f|
          f.write(response.body)
        end

        # Verify PDF was created and has content
        unless File.exist?(pdf_path) && File.size(pdf_path) > 0
          raise "PDF file was not created or is empty"
        end

        # Update job_progress to only store PDF path
        @background_job.update_column(:job_progress, { pdf_report: pdf_path, completed_at: Time.now.utc.iso8601 }.to_json)

        # Cleanup temp HTML
        File.delete(html_path) if File.exist?(html_path)

        Rails.logger.info "BackupTenantJob: PDF report saved to #{pdf_path} (#{File.size(pdf_path)} bytes)"
      rescue => e
        Rails.logger.error "BackupTenantJob: Failed to generate PDF report: #{e.message}"
        Rails.logger.error "URL: #{url}, HTML path: #{html_path}"
        Rails.logger.error e.backtrace.join("\n") if e.backtrace
      end
    end

    def generate_backup_html_report(tenant, summary, archive_path)
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>Backup Report - #{tenant.name}</title>
          <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            h1 { color: #333; }
            h2 { color: #666; margin-top: 30px; }
            table { border-collapse: collapse; width: 100%; margin-top: 20px; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; }
            .meta { color: #666; font-size: 0.9em; }
          </style>
        </head>
        <body>
          <h1>Backup Report</h1>
          <div class="meta">
            <p><strong>Tenant:</strong> #{tenant.name} (ID: #{tenant.id})</p>
            <p><strong>Archive:</strong> #{File.basename(archive_path.to_s)}</p>
            <p><strong>Created:</strong> #{Time.now.utc.iso8601}</p>
          </div>
        #{'  '}
          <h2>Summary</h2>
          <table>
            <tr><th>Step</th><th>Details</th></tr>
            #{summary.select { |item| item.is_a?(Hash) && (item.key?(:step) || item.keys.any? { |k| k.to_s.match?(/_complete|_stats/) }) }.map do |item|
              "<tr><td>#{item[:step] || 'Info'}</td><td>#{item.except(:step).map { |k, v| "#{k}: #{v.is_a?(Array) ? v.size : v}" }.join(', ')}</td></tr>"
            end.join("\n          ")}
          </table>
        </body>
        </html>
      HTML
    end

  def cleanup_old_backups(tenant)
    backup_dir = Rails.root.join("storage", "tenant_backups")
    return unless Dir.exist?(backup_dir)

    cutoff_time = 8.days.ago
    pattern = "tenant_#{tenant.id}_*.tar.gz"

    Dir.glob(File.join(backup_dir, pattern)).each do |file_path|
      # Extract timestamp from filename: tenant_ID_TIMESTAMP.tar.gz
      filename = File.basename(file_path)
      if filename =~ /tenant_\d+_(\d{14})\.tar\.gz/
        timestamp_str = $1
        # Parse timestamp: YYYYMMDDHHMMSS
        file_time = Time.strptime(timestamp_str, "%Y%m%d%H%M%S") rescue nil

        if file_time && file_time < cutoff_time
          File.delete(file_path)
          say "Deleted old backup: #{filename} (created #{file_time})"
        end
      end
    end
  rescue => e
    say "Error cleaning up old backups: #{e.message}"
    # Don't fail the job if cleanup fails
  end
end
