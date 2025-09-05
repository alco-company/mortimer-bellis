require "test_helper"

class RestoreTenantJobRealArchiveTest < ActiveSupport::TestCase
  ARCHIVE_PATH = Rails.root.join("tmp/tenant_1_20250829090541.tar.gz")

  setup do
    @tenant = Tenant.find_by(id: 1)
    skip "Tenant id=1 not found" unless @tenant
    skip "Archive not present at #{ARCHIVE_PATH}" unless File.exist?(ARCHIVE_PATH)
  end

  test "smoke: perform with defaults returns a summary Array" do
    job = RestoreTenantJob.new
    summary = nil
    assert_nothing_raised do
      summary = job.perform(tenant: @tenant, archive_path: ARCHIVE_PATH)
    end
    assert_kind_of Array, summary
  end

  test "dry_run + restore:false returns early (no file_ids or data restore)" do
    job = RestoreTenantJob.new

    # Stubs: keep early phases minimal & detectable
    def job.extract_metadata_file(root, summary)
      summary << ({ phase: :metadata })
      [ summary, {}, [] ]
    end
    def job.purge_or_remap_records(summary, manifest, dir)
      summary << ({ phase: :purge_or_remap_entered })
      [ summary, {} ] # purges hash (not nil) so first early-return condition won't trigger
    end
    # These should NOT be called because restore:false causes early return
    def job.extract_file_ids_file(*)
      raise "extract_file_ids_file should not be called in dry_run early return test"
    end
    def job.restore_data_records(*)
      raise "restore_data_records should not be called in dry_run early return test"
    end

    summary = job.perform(
      tenant: @tenant,
      archive_path: ARCHIVE_PATH,
      dry_run: true,
      restore: false # forces the early return after purge/remap phase
    )

    phases = summary.select { |h| h.is_a?(Hash) }.map { |h| h[:phase] }.compact
    assert_includes phases, :metadata
    assert_includes phases, :purge_or_remap_entered
    refute_includes phases, :file_ids
    refute_includes phases, :data_restored
  end

  test "purge only (purge:true, restore:false) executes purge phase stub and returns early" do
    job = RestoreTenantJob.new

    def job.extract_metadata_file(root, summary)
      summary << ({ phase: :metadata })
      [ summary, {}, [] ]
    end
    def job.purge_or_remap_records(summary, manifest, dir)
      summary << ({ phase: :purge_phase })
      # Simulate purge results (non-nil) so first early-return (purges.nil? && purge) does NOT trigger
      [ summary, {} ]
    end
    def job.extract_file_ids_file(*)
      raise "extract_file_ids_file should not be called when restore:false"
    end

    summary = job.perform(
      tenant: @tenant,
      archive_path: ARCHIVE_PATH,
      purge: true,
      restore: false
    )

    phases = summary.select { |h| h.is_a?(Hash) }.map { |h| h[:phase] }.compact
    assert_includes phases, :metadata
    assert_includes phases, :purge_phase
    refute_includes phases, :file_ids
  end
end
