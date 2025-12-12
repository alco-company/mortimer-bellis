# lib/database_restore.rb

class DatabaseRestore
  SERVER_IP = "your-server-ip"
  SERVER_USER = "root"
  CONTAINER_NAME = "your-app-web"
  LOCAL_BACKUP_DIR = "/path/to/backups"
  RETENTION_DAYS = 30

  def self.run
    puts "Starting database restore..."
    # new.perform_restore
  end

  def perform_restore
    container_id = fetch_container_id
    return unless container_id

    backup_filename = "production_#{Time.current.strftime('%Y%m%d_%H%M%S')}.sqlite3"
    remote_temp_path = "/rails/storage/backup_#{backup_filename}"

    if create_backup(container_id, remote_temp_path) &&
      copy_to_host(container_id, remote_temp_path, backup_filename) &&
      copy_to_local(backup_filename)

      cleanup_remote_files(container_id, remote_temp_path, backup_filename)
      cleanup_old_backups
    end
  end

  private

    def fetch_container_id
      stdout, status = run_ssh_command("docker ps --filter name=#{CONTAINER_NAME} --format '{{.ID}}'")

      container_id = stdout.strip
      if container_id.empty?
        log_message "ERROR: Could not find container ID. Is the container running?"
        return nil
      end

      log_message "Found container ID: #{container_id}"
      container_id
    end

    def create_backup(container_id, remote_temp_path)
      log_message "Creating backup inside container..."

      _, status = run_ssh_command(
        "docker exec #{container_id} bash -c 'cd /rails/storage && sqlite3 production.sqlite3 \".backup #{remote_temp_path}\"'"
      )

      if !status.success?
        log_message "ERROR: Failed to create backup inside container"
        return false
      end

      true
    end

    def copy_to_host(container_id, remote_temp_path, backup_filename)
      log_message "Copying backup from container to host..."

      _, status = run_ssh_command("docker cp #{container_id}:#{remote_temp_path} /root/#{backup_filename}")

      if !status.success?
        log_message "ERROR: Failed to copy backup from container to host"
        run_ssh_command("docker exec #{container_id} rm -f #{remote_temp_path}")
        return false
      end

      true
    end

    def copy_to_local(backup_filename)
      log_message "Copying backup to local machine..."

      _, status = run_command("scp", "#{SERVER_USER}@#{SERVER_IP}:/root/#{backup_filename}", "#{LOCAL_BACKUP_DIR}/#{backup_filename}")

      if !status.success?
        log_message "ERROR: Failed to copy backup to local machine"
        cleanup_remote_files(container_id, remote_temp_path, backup_filename)
        return false
      end

      true
    end

    def cleanup_remote_files(container_id, remote_temp_path, backup_filename)
      log_message "Cleaning up remote temporary files..."
      run_ssh_command("rm -f /root/#{backup_filename} && docker exec #{container_id} rm -f #{remote_temp_path}")
    end

    def verify_and_finalize_backup(backup_filename)
      backup_path = File.join(LOCAL_BACKUP_DIR, backup_filename)

      if !File.exist?(backup_path) || File.zero?(backup_path)
        log_message "ERROR: Backup file is empty or does not exist"
        return
      end

      cleanup_old_backups
      backup_size = `du -h "#{backup_path}"`.split.first

      log_message "Backup completed successfully! File: #{backup_filename} (Size: #{backup_size})"
      log_message "Backup location: #{backup_path}"
    end

    def cleanup_old_backups
      log_message "Cleaning up backups older than #{RETENTION_DAYS} days..."

      Dir.glob(File.join(LOCAL_BACKUP_DIR, "production_*.sqlite3")).each do |file|
        if File.mtime(file) < Time.now - RETENTION_DAYS * 24 * 60 * 60
          File.delete(file)
        end
      end
    end

    def run_ssh_command(command)
      run_command("ssh", "#{SERVER_USER}@#{SERVER_IP}", command)
    end

    def run_command(*command)
      stdout, stderr, status = Open3.capture3(*command)
      [ stdout, status ]
    end

    def log_message(message)
      timestamp = Time.current.strftime("%Y-%m-%d %H:%M:%S")
      message = "[#{timestamp}] #{message}"

      puts message
      File.open(LOG_FILE, "a") { |f| f.puts(message) }
    end
end
