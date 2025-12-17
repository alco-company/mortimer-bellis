# Background Job Management System

## Overview

The application uses a two-tier background job architecture:

1. **Infrastructure Layer**: SolidQueue (Rails 8 built-in job queue)
2. **Business Logic Layer**: Custom `BackgroundJob` model + `BackgroundManagerJob` orchestrator

This design provides tenant-specific job scheduling with flexible recurrence patterns while leveraging SolidQueue's reliable job execution.

## Architecture Components

### 1. SolidQueue (Infrastructure)

**Purpose**: Reliable job queue backend using SQLite

**Configuration**: `config/queue.yml`
```yaml
production:
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "*"
      threads: 3
      processes: 1
      polling_interval: 0.1
```

**Recurring Tasks**: `config/recurring.yml`
```yaml
production:
  background_job_scheduler:
    class: BackgroundManagerJob
    queue: default
    schedule: every second 60
```

The `BackgroundManagerJob` runs every 60 seconds to orchestrate tenant-specific jobs.

### 2. BackgroundManagerJob (Orchestrator)

**Location**: `app/jobs/background_manager_job.rb`

**Purpose**: Meta-scheduler that discovers and enqueues tenant background jobs

**Execution Flow**:
```
Every 60 seconds (via SolidQueue recurring):
  1. Query BackgroundJob.any_jobs_to_run
     (states: un_planned or planned, next_run_at <= now)
  
  2. For each un_planned job:
     - Calculate next_run_at from schedule
     - Transition to 'planned' state
     - Broadcast status update
  
  3. For each planned job:
     - Enqueue via SolidQueue (perform_later)
     - Transition to 'running' state
     - Store SolidQueue job_id
     - Broadcast status update
```

**Key Methods**:
- `perform`: Main orchestration loop
- `plan_job(job)`: Calculates next run time and updates state
- `run_job(job)`: Enqueues job with SolidQueue

### 3. BackgroundJob Model

**Location**: `app/models/background_job.rb`

**Purpose**: Database representation of tenant-specific scheduled jobs

**Schema**:
```ruby
tenant_id       # Tenant ownership
user_id         # User who created the job
state           # Lifecycle state (enum)
job_klass       # Job class name (e.g., "SendEmailJob")
params          # JSON parameters for job
schedule        # Cron or RRULE format
next_run_at     # Calculated next execution time
job_id          # SolidQueue job identifier
```

**State Machine**:
```
in_active (0)  -> Job disabled/inactive
un_planned (1) -> Job enabled, needs scheduling
planned (2)    -> Job scheduled, awaiting execution
running (3)    -> Job currently executing
failed (4)     -> Job execution failed
finished (5)   -> Job completed (one-time jobs only)
```

**Key Scopes**:
- `any_jobs_to_run`: Returns jobs in states 1-2 with `next_run_at <= Time.now`

### 4. Queueable Concern

**Location**: `app/models/concerns/queueable.rb`

**Purpose**: Provides job lifecycle management and scheduling logic

**Key Methods**:

#### `plan_job(first = false)`
Calculates next run time and transitions to 'planned' state.

```ruby
# Parse schedule (cron or RRULE)
# Calculate next_run_at
# Update state to 'planned'
# Enqueue job if first == true
```

#### `run_job(t = Time.now)`
Enqueues job with SolidQueue.

```ruby
# Get job class (e.g., SendEmailJob)
# Parse parameters with set_parms
# Call job_klass.perform_later(params)
# Update state to 'running'
# Store SolidQueue job_id
```

#### `job_done(success: true, result: "")`
Callback invoked when job completes.

```ruby
# If recurring: schedule next run (state -> un_planned)
# If one-time: mark finished (state -> finished)
# If failed: mark failed (state -> failed)
# Broadcast status update
```

#### `set_parms`
Dynamic parameter parsing with special keywords:

```ruby
# Keywords:
me     -> Current user object
tenant -> Current tenant object
team   -> Current team object
self   -> BackgroundJob record itself

# Supports eval for dynamic values
params = "{ user_id: me.id, date: Time.now }"
```

#### `next_run(t = Time.now)`
Parses schedule and calculates next execution time.

**Supported Formats**:
- **Cron**: `0 9 * * *` (every day at 9am)
- **RRULE**: `FREQ=DAILY;INTERVAL=1;BYHOUR=9` (RFC 5545)

Uses `CronTask` and `RRuleEngine` for parsing.

## Execution Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ SolidQueue Recurring Task (every 60 seconds)               │
│                                                             │
│  BackgroundManagerJob.perform                              │
│    │                                                        │
│    ├─> Query: BackgroundJob.any_jobs_to_run                │
│    │          (un_planned OR planned) AND next_run_at <= now│
│    │                                                        │
│    ├─> For each un_planned job:                            │
│    │     plan_job() -> Calculate next_run_at               │
│    │                -> State: un_planned -> planned        │
│    │                                                        │
│    └─> For each planned job:                               │
│         run_job()  -> Enqueue with SolidQueue              │
│                    -> State: planned -> running            │
│                    -> Store job_id                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│ SolidQueue Worker (processes: 1, threads: 3)               │
│                                                             │
│  Executes: SendEmailJob.perform(params)                    │
│            BackupTenantJob.perform(params)                 │
│            etc.                                             │
│                                                             │
│  On completion:                                             │
│    Calls back: BackgroundJob.job_done(success:, result:)   │
│      │                                                      │
│      ├─> If recurring: State: running -> un_planned        │
│      │                 (will be picked up next cycle)      │
│      │                                                      │
│      └─> If one-time: State: running -> finished           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## State Transitions

```
[in_active] ──enable──> [un_planned]
                            │
                            │ BackgroundManagerJob.plan_job()
                            ▼
                        [planned]
                            │
                            │ BackgroundManagerJob.run_job()
                            ▼
                        [running]
                            │
                ┌───────────┴───────────┐
                │                       │
          job_done(success)      job_done(failure)
                │                       │
                ▼                       ▼
    ┌──────────────────────┐      [failed]
    │                      │
    │ Recurring?           │
    ├─Yes─> [un_planned]   │
    │        (reschedule)  │
    │                      │
    └─No──> [finished]     │
            (one-time)     │
```

## Configuration Examples

### Example 1: Daily Backup at 2am

```ruby
BackgroundJob.create!(
  tenant: current_tenant,
  user: current_user,
  job_klass: "BackupTenantJob",
  schedule: "0 2 * * *",  # Cron: 2am daily
  params: { compression: true },
  state: :un_planned
)
```

### Example 2: Weekly Report (RRULE)

```ruby
BackgroundJob.create!(
  tenant: current_tenant,
  user: current_user,
  job_klass: "SendReportJob",
  schedule: "FREQ=WEEKLY;BYDAY=MO;BYHOUR=9",  # Mondays at 9am
  params: { report_type: "sales", recipients: ["team@example.com"] },
  state: :un_planned
)
```

### Example 3: One-time Job

```ruby
BackgroundJob.create!(
  tenant: current_tenant,
  user: current_user,
  job_klass: "ImportDataJob",
  schedule: nil,  # No recurrence
  params: { file_id: 123 },
  state: :planned,
  next_run_at: Time.now + 5.minutes
)
```

## Implementing a Background Job

### Step 1: Create Job Class

```ruby
# app/jobs/send_email_job.rb
class SendEmailJob < ApplicationJob
  queue_as :default

  def perform(params)
    background_job_id = params[:background_job_id]
    background_job = BackgroundJob.find(background_job_id)
    
    begin
      # Your job logic here
      user = User.find(params[:user_id])
      SomeMailer.notification(user).deliver_now
      
      # Mark success
      background_job.job_done(success: true, result: "Email sent")
    rescue => e
      # Mark failure
      background_job.job_done(success: false, result: e.message)
    end
  end
end
```

### Step 2: Create BackgroundJob Record

```ruby
# In controller or service
BackgroundJob.create!(
  tenant: current_tenant,
  user: current_user,
  job_klass: "SendEmailJob",
  schedule: "0 9 * * 1-5",  # Weekdays at 9am
  params: { user_id: current_user.id },
  state: :un_planned
)
```

### Step 3: Job Executes Automatically

The `BackgroundManagerJob` will:
1. Detect the un_planned job (next cycle, within 60 seconds)
2. Calculate `next_run_at` from schedule
3. Transition to `planned` state
4. When `next_run_at` arrives, enqueue with SolidQueue
5. Your job executes and calls `job_done`
6. If recurring, job returns to `un_planned` for next cycle

## Parameter Parsing with `set_parms`

The `set_parms` method supports dynamic parameter evaluation:

```ruby
# Static parameters
params = { user_id: 123, action: "backup" }

# Dynamic parameters with keywords
params = "{ user_id: me.id, tenant_id: tenant.id, timestamp: Time.now }"

# Special keywords:
# - me: current_user
# - tenant: current_tenant
# - team: current_team
# - self: the BackgroundJob record
```

**Example**:
```ruby
BackgroundJob.create!(
  tenant: current_tenant,
  user: current_user,
  job_klass: "DailyReportJob",
  params: "{ user_id: me.id, date: Date.today, tenant_name: tenant.name }",
  schedule: "0 8 * * *"
)

# At execution, set_parms evaluates to:
# { user_id: 42, date: "2025-11-20", tenant_name: "Acme Corp" }
```

## Monitoring and Debugging

### Check Job Status

```ruby
# All jobs for a tenant
BackgroundJob.where(tenant: current_tenant)

# Jobs ready to run
BackgroundJob.any_jobs_to_run

# Failed jobs
BackgroundJob.where(state: :failed)

# Running jobs
BackgroundJob.where(state: :running)
```

### View SolidQueue Status

```ruby
# Active jobs in queue
SolidQueue::Job.where(finished_at: nil)

# Failed jobs
SolidQueue::FailedExecution.all

# Recurring tasks
SolidQueue::RecurringTask.all
```

### Common Issues

**Job not running?**
- Check `state`: Should be `un_planned` or `planned`
- Check `next_run_at`: Should be <= current time
- Check `BackgroundManagerJob` is running (view logs)
- Verify `config/recurring.yml` is loaded

**Job stuck in 'running'?**
- Job may have crashed without calling `job_done`
- Check SolidQueue logs for errors
- Manually reset: `job.update(state: :un_planned)`

**Schedule not working?**
- Validate cron syntax: Use [crontab.guru](https://crontab.guru)
- Validate RRULE syntax: Check RFC 5545 format
- Verify timezone handling in `next_run` method

## Testing Background Jobs

```ruby
# test/jobs/my_job_test.rb
class MyJobTest < ActiveJob::TestCase
  test "job completes successfully" do
    job = background_jobs(:daily_backup)
    
    assert_difference -> { BackgroundJob.where(state: :finished).count }, 1 do
      MyJob.perform_now(background_job_id: job.id, other: "params")
    end
    
    job.reload
    assert_equal "finished", job.state
  end
  
  test "job reschedules on recurring" do
    job = background_jobs(:recurring_report)
    job.update(schedule: "0 9 * * *")
    
    MyJob.perform_now(background_job_id: job.id)
    
    job.reload
    assert_equal "un_planned", job.state
    assert_not_nil job.next_run_at
  end
end
```

## Performance Considerations

### Polling Interval

The `BackgroundManagerJob` runs every 60 seconds by default. Adjust in `config/recurring.yml`:

```yaml
production:
  background_job_scheduler:
    schedule: every second 30  # Check every 30 seconds
```

**Trade-off**: Lower interval = faster job pickup, higher database load

### Batch Size

SolidQueue processes jobs in batches. Adjust in `config/queue.yml`:

```yaml
production:
  dispatchers:
    - batch_size: 500  # Process up to 500 jobs per cycle
```

### Worker Threads

Control concurrency with worker threads:

```yaml
production:
  workers:
    - threads: 5  # Run 5 jobs concurrently
```

## Security Considerations

1. **Parameter Evaluation**: The `eval` in `set_parms` can execute arbitrary code. Ensure:
   - Only trusted users can create BackgroundJobs
   - Validate `params` format before saving
   - Consider sandboxing eval or using a safer parser

2. **Tenant Isolation**: Jobs are scoped to tenants via `tenant_id`. Ensure:
   - Job classes respect tenant context
   - Use `ActsAsTenant.with_tenant(job.tenant)` in perform method

3. **Job Authorization**: Verify users can only create jobs they're authorized for

## Future Enhancements

- **Job Priority**: Add `priority` field to BackgroundJob for execution ordering
- **Job Timeout**: Add `timeout` field to kill long-running jobs
- **Job Chains**: Support job dependencies (run JobB after JobA completes)
- **Job Retries**: Configurable retry logic for failed jobs
- **Dashboard UI**: Web interface for managing jobs (create, pause, delete, view logs)
- **Audit Log**: Track job execution history and parameter changes

## Summary

The background job system provides:
- ✅ Tenant-specific job scheduling
- ✅ Flexible recurrence (cron, RRULE)
- ✅ Dynamic parameter evaluation
- ✅ State-based lifecycle management
- ✅ Integration with SolidQueue for reliability
- ✅ Automatic rescheduling for recurring jobs

**Key Files**:
- `app/jobs/background_manager_job.rb` - Orchestrator
- `app/models/background_job.rb` - Database model
- `app/models/concerns/queueable.rb` - Lifecycle logic
- `config/recurring.yml` - SolidQueue recurring tasks
- `config/queue.yml` - SolidQueue configuration
