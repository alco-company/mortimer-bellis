# Work State Summary

## Recent Updates (Aug 27 2025 – Backup/Restore Hardening Phase 2)
- Added metadata.json to backups (schema_version, git SHA, created_at, tenant_id, dump SHA256, attachment count).
- Removed raw ActiveStorage direct insert fallback; now uniform save! logic.
- Implemented full purge (always all tenant-scoped models via DependencyGraph.purge_order) to prevent orphan FK violations.
- Enhanced collision handling:
  - pre_scan_collisions now scans regardless of allow_remap; collisions recorded even when remap disabled.
  - Early abort when RESTORE_NO_REMAP=1 and collisions detected.
  - Always persist id remap entries (even unchanged IDs) in id_remap_manifest.
- Added feature-flagged per-record diagnostics (RESTORE_DEBUG_RECORDS) limited to first 200 records per model.
- Added multi-level collision test (Customer -> Project -> Invoice) verifying remap propagation to grandchildren.
- Added RESTORE_NO_REMAP failure test asserting early raise on collision with remap disabled.
- Updated backup completeness test to assert metadata.json presence.
- Added comprehensive full purge helper for tests to avoid legacy FK residue.
- Improved restore logging: fk violations captured into summary instead of immediate raise; detailed sample rows logged.

## Current Gaps / Issues
- BackupRestoreStrictTest: consistent restore test required full purge pre-step; fixture adjusted but need to re-run to confirm green (ensure test file saved & executed successfully after edits).
- Need to clean/confirm remaining foreign key constraint failures do not appear with new full purge; if they persist, add pre-run full purge for all restore tests.
- Per-record diagnostics currently silent unless RESTORE_DEBUG_RECORDS set; consider adding summary counts (records_attempted, deferred_count, remaps_total).
- ActiveStorage restore still copies blob files but does not validate checksum alignment; potential enhancement.
- No verification step for dump SHA256 on restore (metadata.json hash currently only produced on backup).
- Tests do not yet assert fk_violations total_fk_violations == 0 for successful restores; could add.

## Next Steps (Prioritized)
1. Test Stabilization & Coverage
   - Re-run full test suite; ensure backup_restore_strict_test passes after full purge additions.
   - Add assertion in collision tests for presence of id_remap_manifest mapping value (symbol :pending should be resolved to final id; verify no lingering :pending entries post-restore).
   - Add test asserting fk_violations total == 0 for a clean restore scenario.
2. Manifest & Integrity
   - Generate metadata.json during restore to echo backup metadata & optionally verify dump.jsonl SHA256.
   - Write verification log step (step: :metadata_verified or :metadata_mismatch).
3. Summary Metrics
   - Add summary counters: collisions_detected, remaps_finalized, deferred_records_total, retry_passes_used.
   - Include these counters in background job job_progress for UI.
4. Configurability
   - Introduce RESTORE_MAX_PASSES env var (default 5) replacing hard-coded max_passes.
   - Add RESTORE_DISABLE_ACTIVE_STORAGE flag for faster dry-runs.
5. Foreign Key Robustness
   - After final insert pass, attempt targeted re-insert of any deferred records still failing (log reason) before reporting violations.
   - Provide optional ENV to ignore specific models (RESTORE_SKIP_MODELS) for emergency partial loads.
6. ActiveStorage Enhancements
   - Compute and log each blob checksum; skip copy if identical blob exists (deduplicate).
   - Optionally compress blobs directory inside archive (tar already does global compression; measure benefit).
7. Code Cleanup
   - Remove duplicate purge invocation remnants (already fixed) & ensure no residual debug logs outside flag.
   - Extract restore phases into smaller private methods for maintainability.
8. Documentation
   - Update README / internal docs to describe new feature flags and metadata.json fields.
   - Provide runbook for handling collision failures and interpreting id_remap_manifest.

## Open Decisions
- Should restore validate dump SHA against metadata.json and abort on mismatch (integrity guarantee) or only warn?
- Limit remap manifest size in job_progress (truncate large maps) vs full file only.
- Whether to persist per-record diagnostics to a separate debug log for post-mortem (current fallback log rotates daily).

## Ready For Next Session
Provide / Decide:
- Full test suite results after current changes.
- Decision on implementing metadata verification during restore.
- Preference for adding fk_violations==0 assertions in tests.
- Approval to add RESTORE_MAX_PASSES and RESTORE_SKIP_MODELS.
- Any additional metrics desired in summary/job_progress.

## Suggested Next Chat Prompt
"Run full test suite; ensure backup_restore_strict_test passes with full purge. Then add fk_violations==0 assertion, metadata verification on restore (using metadata.json + SHA256), and summary counters (collisions_detected, remaps_finalized, deferred_records_total, retry_passes_used). Implement RESTORE_MAX_PASSES env and optional RESTORE_SKIP_MODELS."
