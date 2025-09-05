require "test_helper"
require "tmpdir"

class RestoreTenantJobSkipModelsTest < ActiveSupport::TestCase
  # Subclass to capture which models actually get processed in restore_data_records
  class CapturingRestoreTenantJob < RestoreTenantJob
    attr_reader :processed_models

    def initialize
      super
      @processed_models = []
    end

    # Intercept the 'puts row["data"]' side‑effect to record model names instead
    def restore_data_records(extracted_root, summary, file_ids)
      restores = {}
      begin
        dump_file = extracted_root.join("dump.jsonl")
        raise "dump.jsonl missing" unless File.exist?(dump_file)
        File.foreach(dump_file) do |line|
          next if line.strip.empty?
            row = JSON.parse(line)
          next if setting(:skip_models).include?(row["model"])
          @processed_models << row["model"]
          # (Original code just: puts row["data"])
        end
      rescue => e
        summary << ({ dump_file: dump_file, file_ids: file_ids })
        log_progress(summary, step: :restore_data_records, message: e.message)
      end
      [ summary, restores ]
    end
  end

  setup do
    @tenant = Tenant.first || Tenant.create!(name: "TestTenant") rescue Tenant.create!(name: "TestTenant")
  end

  def build_archive(models: %w[tenants settings users])
    Dir.mktmpdir("restore_skip_models") do |dir|
      root_dir = File.join(dir, "backup_root")
      FileUtils.mkdir_p(root_dir)

      # Minimal required files for current implementation
      File.write(File.join(root_dir, "metadata.json"), JSON.dump({ "record_dump_sha256" => "dummy" }))
      File.write(File.join(root_dir, "manifest.json"), JSON.dump({})) # current code treats as hash
      File.write(File.join(root_dir, "file_ids.jsonl"), "{}")

      dump_lines = models.map.with_index do |m, idx|
        { model: m, data: { id: idx + 1 } }.to_json
      end
      File.write(File.join(root_dir, "dump.jsonl"), dump_lines.join("\n"))

      archive_path = File.join(dir, "backup.tar.gz")
      Dir.chdir(dir) { system("tar -czf #{archive_path} backup_root") or raise "tar failed" }
      yield archive_path
    end
  end

  test "skip_models excludes tenants and settings from processing" do
    build_archive do |archive|
      job = CapturingRestoreTenantJob.new
      summary = job.perform(
        tenant: @tenant,
        archive_path: archive,
        skip_models: "tenants,settings",
        # keep defaults: remap true, restore true
      )

      # Only 'users' should have been processed
      assert_equal [ "users" ], job.processed_models.sort, "Expected only non-skipped models to be processed"
      skipped = job.send(:setting, :skip_models)
      assert_equal %w[settings tenants], skipped.sort

      # Summary should still be an Array
      assert_kind_of Array, summary
    end
  end

  test "no skip_models processes all models" do
    build_archive do |archive|
      job = CapturingRestoreTenantJob.new
      job.perform(
        tenant: @tenant,
        archive_path: archive
      )
      assert_equal %w[settings tenants users].sort, job.processed_models.sort
    end
  end
end
