# lib/database_backup.rb
require "open3"
require "net/sftp"

class DatabaseBackup
  LOG_FILE = "#{Dir.home}/sqlite3_dumps/backup_log"
  STAGING_SERVER = "135.181.202.106"
  PRODUCTION_SERVER = "65.108.89.110"
  USER = "root"

  attr_accessor :ftp_user, :ftp_password, :ftp_server

  def initialize
    puts "Initializing DatabaseBackup..."
    @ftp_user = ENV["FTP_USER"] || nil
    @ftp_password = ENV["FTP_PASSWORD"] || nil
    @ftp_server = ENV["FTP_SERVER"] || nil
    puts "Please set FTP_USER, FTP_PASSWORD, and FTP_SERVER environment variables to complete FTP upload to FTP_SERVER after backup." unless ftp_user && ftp_password && ftp_server
  end
  #
  #
  def self.run
    puts "Starting database backup..."
    env = ENV["KAMAL_ENV"]
    unless env
      puts "Please set KAMAL_ENV environment variable (e.g., KAMAL_ENV=staging, development or production)"
      return 1
    end
    puts "Using KAMAL_ENV=#{env} for backup"
    new.perform_backup env: env
  end

  def perform_backup(env:)
    d_env = env == "development" ? "development" : "production"
    db_file = YAML.load_file("config/database.yml", aliases: true)[d_env]["writer"]["database"]
    time = Time.current.strftime("%Y%m%d_%H%M%S")
    backup_filename = db_file.split("/")[-1].split(".")[0] + "_#{time}.sqlite3"
    remote_temp_path = "backup_#{backup_filename}"

    if create_backup(env: env, db_file: db_file, remote_temp_path: remote_temp_path) &&
       copy_to_host(env: env, time: time) &&
       copy_to_local(env: env, time: time)

       cleanup_remote_files(env: env)
       ftp_backup(env: env, time: time)
       verify_and_finalize_backup(env: env, time: time)
      #  cleanup_old_backups
    end
  end

  private

    def create_backup(env:, db_file:, remote_temp_path:)
      bck_path = "storage/backup"
      docker_storage = "/var/lib/docker/volumes/storage/_data"

      case env
      when "staging"
        _, status = run_command "kamal app -d staging exec \"mkdir -p #{bck_path} || exit 1\""
        return false unless status.success?
        log_message "Creating a backup of #{Dir.pwd}/#{db_file} in #{bck_path}, in the container..."
        _, status = run_command "kamal app -d staging exec \"sqlite3 #{db_file} '.backup storage/backup/#{remote_temp_path}' || exit 1\""
        return false unless status.success?
        log_message "Copying Active Storage files to #{bck_path}, in the container..."
        _, status = run_command "ssh root@135.181.202.106 \"cp -rf #{docker_storage}/?? #{docker_storage}/backup/ || exit 1\""

      when "production"
        _, status = run_command "kamal app exec \"mkdir -p #{bck_path} || exit 1\""
        return false unless status.success?
        log_message "Creating a backup of #{Dir.pwd}/#{db_file} in #{bck_path}, in the container..."
        _, status = run_command "kamal app exec \"sqlite3 #{db_file} '.backup storage/backup/#{remote_temp_path}' || exit 1\""
        return false unless status.success?
        log_message "Copying Active Storage files to #{bck_path}, in the container..."
        _, status = run_command "ssh root@65.108.89.110 \"cp -rf #{docker_storage}/?? #{docker_storage}/backup/ || exit 1\""

      else
        _, status = run_command "mkdir -p storage/backup || exit 1"
        return false unless status.success?
        _, status = run_command "sqlite3 #{db_file} \".backup storage/backup/#{remote_temp_path}\" || exit 1"
        return false unless status.success?
        log_message "Copying Active Storage files to storage/backup/.."
        _, status = run_command "cp -rf storage/?? #{bck_path} || exit 1"

      end

      if !status.success?
        log_message "ERROR: Failed to create backup of #{Dir.pwd}/#{db_file} "
        return false
      end
      true
    end

    def copy_to_host(env:, time:)
      case env
      when "staging"
        log_message "Taring the backup from staging container to /root/backup.tar.gz..."
        _, status = run_command "ssh root@135.181.202.106 'tar -zcvf /root/backup.tar.gz /var/lib/docker/volumes/storage/_data/backup' || exit 1"
        # _, status = run_command "ssh root@135.181.202.106 'mv /var/lib/docker/volumes/storage/_data/backup /root' || exit 1"
      when "production"
        log_message "Taring the backup from production container to /root/backup.tar.gz..."
        _, status = run_command "ssh root@65.108.89.110 'tar -zcvf /root/backup.tar.gz /var/lib/docker/volumes/storage/_data/backup' || exit 1"
        # _, status = run_command "ssh root@65.108.89.110 'mv /var/lib/docker/volumes/storage/_data/backup /root' || exit 1"
      else
        log_message "Taring the backup to ~/backup.tar.gz..."
        _, status = run_command "tar -zcvf ~/backup.tar.gz storage/backup || exit 1"
      end

      if !status.success?
        log_message "ERROR: Failed to move backup from container to host"
        return false
      end

      true
    end

    def copy_to_local(env:, time:)
      log_message "Copying the backup.tar.gz to ~/sqlite3_dumps/#{env}/#{time}_backup.tar.gz..."
      case env
      when "staging"
        _, status = run_command "scp root@135.181.202.106:backup.tar.gz ~/sqlite3_dumps/staging/#{time}_backup.tar.gz || exit 1"
      when "production"
        _, status = run_command "scp root@65.108.89.110:backup.tar.gz ~/sqlite3_dumps/production/#{time}_backup.tar.gz || exit 1"
      else
        _, status = run_command "mv ~/backup.tar.gz ~/sqlite3_dumps/development/#{time}_backup.tar.gz || exit 1"
      end

      if !status.success?
        log_message "ERROR: Failed to copy backup to ~/sqlite3_dumps/#{env}/#{time}_backup.tar.gz"
        return false
      end
      true
    end

    def cleanup_remote_files(env:)
      log_message "Cleaning up temporary files..."
      case env
      when "staging"
        _, status = run_command "ssh root@135.181.202.106 'rm /root/backup.tar.gz' || exit 1"
      when "production"
        _, status = run_command "ssh root@65.108.89.110 'rm /root/backup.tar.gz' || exit 1"
      else
        _, status = run_command "ls -la ~ || exit 1"
      end

      if !status.success?
        log_message "ERROR: Failed to clean up remote backup file /root/backup.tar.gz"
        return false
      end
      true
    end

    def ftp_backup(env:, time:)
      return unless ftp_user && ftp_password && ftp_server
      log_message "Uploading #{env}/#{time}_backup.tar.gz to FTP server #{ftp_server}..."
      Net::SFTP.start(ftp_server, ftp_user, password: ftp_password) do |sftp|
        case env
        when "staging"
          local_path = File.join(Dir.home, "sqlite3_dumps", "staging", "#{time}_backup.tar.gz")
          remote_path = "/Hetzner/staging/#{time}_backup.tar.gz"
        when "production"
          local_path = File.join(Dir.home, "sqlite3_dumps", "production", "#{time}_backup.tar.gz")
          remote_path = "/Hetzner/mortimer/#{time}_backup.tar.gz"
        else
          local_path = File.join(Dir.home, "sqlite3_dumps", "development", "#{time}_backup.tar.gz")
          remote_path = "/Hetzner/staging/dev_#{time}_backup.tar.gz"
        end
        sftp.upload!(local_path, remote_path)
      end
    end

    def verify_and_finalize_backup(env:, time:)
      return unless ftp_user && ftp_password && ftp_server
      log_message "Verifying and finalizing backup of #{time}_backup.tar.gz..."
      dev = env == "development" ? "dev_" : ""
      local_path = remote_path = ""
      Net::SFTP.start(ftp_server, ftp_user, password: ftp_password) do |sftp|
        ftp_file = local_path = nil
        case env
        when "staging"
          local_path = File.join(Dir.home, "sqlite3_dumps", "staging", "#{time}_backup.tar.gz")
          remote_path = "/Hetzner/staging"
        when "production"
          local_path = File.join(Dir.home, "sqlite3_dumps", "production", "#{time}_backup.tar.gz")
          remote_path = "/Hetzner/mortimer"
        else
          local_path = File.join(Dir.home, "sqlite3_dumps", "development", "#{time}_backup.tar.gz")
          remote_path = "/Hetzner/staging"
        end
        sftp.dir.foreach(remote_path) do |entry|
          ftp_file = entry.longname if entry.longname =~ /#{dev}#{time}_backup.tar.gz/
        end

        if !File.exist?(local_path) || File.zero?(local_path)
          log_message "ERROR: Backup file is empty or does not exist"
          return false
        end

        if !ftp_file || ftp_file.split(" ")[-5].to_i < 1
          log_message "ERROR: Backup file on FTP server is empty or does not exist"
          return false
        end
      end

      # cleanup_old_backups
      backup_size = `du --si "#{local_path}"`.split.first

      log_message "Backup completed successfully! File: #{time}_backup.tar.gz (Size: #{backup_size})"
      log_message "Backup location: #{remote_path}/#{dev}#{time}_backup.tar.gz"
    end

    def cleanup_old_backups
      # log_message "Cleaning up backups older than #{RETENTION_DAYS} days..."

      # Dir.glob(File.join(LOCAL_BACKUP_DIR, "production_*.sqlite3")).each do |file|
      #   if File.mtime(file) < Time.now - RETENTION_DAYS * 24 * 60 * 60
      #     File.delete(file)
      #   end
      # end
    end

    # def fetch_container_id
    #   stdout, status = run_ssh_command("docker ps --filter name=#{CONTAINER_NAME} --format '{{.ID}}'")

    #   container_id = stdout.strip
    #   if container_id.empty?
    #     log_message "ERROR: Could not find container ID. Is the container running?"
    #     return nil
    #   end

    #   log_message "Found container ID: #{container_id}"
    #   container_id
    # end

    # def run_ssh_command(command)
    #   run_command("ssh", "#{SERVER_USER}@#{SERVER_IP}", command)
    # end

    def run_command(*command)
      stdout, _stderr, status = Open3.capture3(*command)
      [ stdout, status ]
    end

    def log_message(message)
      timestamp = Time.current.strftime("%Y-%m-%d %H:%M:%S")
      message = "[#{timestamp}] #{message}"

      puts message
      File.open(LOG_FILE, "a") { |f| f.puts(message) }
    end
end
