# Work State Summary

## Accomplished

1. Fixed failing model tests:
   - Refactored `Setting.time_material_settings`, `team_settings`, and `user_settings` to use a unified `klass_for` + `build_settings_for` approach for deterministic test behavior.
   - Adjusted settings test expectations now passing (confirmed by running `test/models/setting_test.rb`).

2. Added / refined default settings logic:
   - Prevents duplicate creation at different scoping levels (tenant, class, instance) in test mode.

3. Live search improvements:
   - Debounce increased to 500ms.
   - Prevent duplicate / nested query params.
   - Immediate execution on Enter.
   - Composition (IME) safe.
   - Avoid redundant requests on identical input.

4. Fixed time/material permissions & consistency issues uncovered by tests.

5. Added comprehensive tenant backup system:
   - `BackupTenantJob` created.
   - Scans all tables with `tenant_id` (DB-introspection based, not just loaded models).
   - Dumps newline-delimited JSON (dump.jsonl) for each row.
   - Writes `manifest.json` with per-table counts and errors.
   - Captures related ActiveStorage attachments & blobs and copies binary blob files (disk service) into archive.
   - Archives everything into `tenant_<id>_<timestamp>.tar.gz` in `tmp/`.
   - Sends notification email (`TenantMailer.backup_created`).
   - Added progress logging to `BackupTenantJob` stored in new `background_jobs.job_progress` (JSON structure with capped log array).

6. Added tenant restore system:
   - `RestoreTenantJob` created.
   - Supports options: `dry_run`, `purge`, `restore` (three-phase, each optional). Default: restore (no purge, no dry run).
   - Tenant ID remapping (`remap`) supported.
   - Priority-based model ordering to respect dependencies.
   - Transaction wrapper around entire purge + restore operation.
   - Dry run reports planned insert/update counts and planned purges without changing data.
   - Purge mode deletes existing tenant rows first (unless dry run).
   - Restores ActiveStorage blobs then attachments (with key collision safety) only when not dry run and restore enabled.
   - Sends completion email (`TenantMailer.restore_completed`).

7. Extended restore job features:
   - Integrated progress logging hook calls (placeholders present) similar to backup job.
   - Added migration for `background_jobs.job_progress` and updated `BackupTenantJob` to use it.

8. Added migration:
   - `20250826220000_add_job_progress_to_background_jobs.rb` introducing `job_progress` column (text) to capture structured progress info.

## Pending / TODO

1. `RestoreTenantJob` progress logging method not yet implemented (log calls exist but method body missing).
   - Need to add a `log_progress` method (similar to backup) that writes to `background_jobs.job_progress`.
   - Decide logging style: either keep existing calls with signature `log_progress(summary, step: ..., **data)` or simplify to `log_progress(step:, **data)`.

2. Optionally cap or rotate archive retention (cleanup job for old backups in `tmp/`).

3. Optional enhancements:
   - Encryption/compression hardening (e.g. AES encryption of archive).
   - Integrity checks (store SHA256 of dump + manifest).
   - Partial restore (model whitelist / blacklist).
   - Bulk inserts (e.g. `insert_all`) for performance (if moving off SQLite).
   - Validation toggle per model during restore.
   - Sequence/PK reset logic (not critical on SQLite).

4. UI / API surface:
   - Expose progress (poll `background_job.job_progress` JSON) in an admin or jobs dashboard.

5. Add `log_progress` to `RestoreTenantJob` and include final summary in `job_progress` (and mark completion / failure steps similarly to backup).

## Usage Examples

### Backup
```
background = BackgroundJob.create!(tenant: Tenant.first, job_klass: 'BackupTenantJob', state: :planned)
BackupTenantJob.perform_later(tenant: Tenant.first, user: User.first, background_job: background)
```
Progress JSON accumulates in `background.job_progress`.

### Restore (Dry Run + Purge Plan)
```
RestoreTenantJob.perform_later(
  tenant: Tenant.first,
  user: User.first,
  archive_path: '/path/to/tenant_1_2025....tar.gz',
  dry_run: true,
  purge: true,
  restore: true
)
```
No data changed; summary and planned counts logged.

### Full Purge + Restore
```
RestoreTenantJob.perform_later(
  tenant: Tenant.first,
  user: User.first,
  archive_path: '/path/to/archive.tar.gz',
  purge: true,
  restore: true
)
```

### Backup Progress Structure (example)
`background_jobs.job_progress` JSON:
```
{
  "log": [
    {"step":"start","at":"2025-08-26T20:57:36Z"},
    {"step":"scan_tables","at":"..."},
    {"step":"dump_progress","table":"products","processed":120,...},
    {"step":"archive_created","path":"/.../tenant_1_...tar.gz","at":"..."},
    {"step":"email_enqueued","at":"..."}
  ]
}
```

## Implementation Notes

- All dump and restore operations are tenant-scoped by presence of `tenant_id` column on tables.
- ActiveStorage export only includes blobs referenced by tenant-owned attachments.
- Restore logic remaps `tenant_id` if `remap: true` and assigns to target tenant.
- Restore runs inside a DB transaction for atomicity (SQLite: still provides rollback on failure).
- Dry run path never alters DB, only computes planning metadata.

## Resetting the Chat / Reloading Context

To start a fresh conversation while preserving context:

1. Commit or keep this `WORKSTATE.md` file as the canonical state summary.
2. Begin the new chat with a short message referencing this file, e.g.:
   "Context: see WORKSTATE.md for current backup/restore + settings state. Next task: implement log_progress in RestoreTenantJob (Option B)."
3. If using a system that cannot read files automatically, paste only the pertinent excerpt (Accomplished + Pending sections) into the first new message.
4. For future tasks, append changes to `WORKSTATE.md` (do not overwrite) under new dated sections to maintain a changelog.
5. To reload context for the assistant: provide the latest `WORKSTATE.md` contents (or at minimum the Pending / TODO section) in the first prompt of the new session.

## Recommendation for Next Step

Implement `RestoreTenantJob#log_progress` (choose Option A or B) and unify logging patterns between backup and restore.

---
Generated on: #{Time.now.utc.iso8601}
