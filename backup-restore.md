# Backup and Restore

## Backup

### System wide backup

Every night there is a cron job doing a complete database backup - which you will use in the event that
the entire system is damaged. Backups are off-loaded to adslthi.alco.dk/Hetzner/mortimer.

### Tenant backup

Tenant backups are created by the tenant themselves - by setting a cron schedule for a background_job
labeled BackupTenantJob, with an argument "controller:background_jobs". The schedule could be "1 1 * * 2-6"
which means backups will be done every Tue-Saturday at 1minute past 1AM in the night.

The last 7 backups are present in the Dashboard for the user to restore.

Every backup is email'ed as a link for the user to store offline. 

IF the user wishes to restore an older backup they may contact support and get instructions. Support will
ask for the backup in question, and relabel it to tenant_[tenant.id]_[today] and then the user can click on
it in their dashboard and restore to that point in time.

## Restore

### System wide restore

In the event the server crashes and has to be restored 'from scratch' it is necessary to use
the commands

```bash
kamal deploy 
kamal app exec --interactive --reuse "bin/rails db:migrate"
```

That will install all necessary files on a newly created VM.

#### Not crashed but bruised

If the VM is still "fighting" and you 'just' need to restore an older backup - you can stop the containers
with `kamal app stop` or ssh into the server and do `docker stop [mortimer-container-name]`

Now either rebuild the cache, cable, and queue databases with `kamal app exec --interactive --reuse "bin/rails db:migrate"`
or move on to the next paragraph.

In order to introduce the latest data set, open Filezilla (or equivalent app) and pull latest
backup from adslthi.alco.dk/Hetzner/mortimer into some folder locally, and decompress the tar.gz into 
that folder, and then do

```bash
cd [folder]
cd root/backup
scp -rp ./* [server]:/var/lib/docker/volumes/storage/_data/
```

Finally, you need to `ssh [server]` in order to set the permissions straight on the database files with

```bash
ssh [server]
cd /var/lib/docker/volumes/storage/_data/
chmod 660 prod*
```

Now you should be back to the minute of that backup. Start the container with `kamal app start` and
test that you can login, add a background job, time_material tasks, more