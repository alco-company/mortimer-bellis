# README

Mortimer Time & Attendance (MTA) is _your fastest from job done to invoice sent_. You get a back office
with tenants, users, locations, teams, projects, more, and you get a _front office_ with
time_material and exporting to CSV, and later PDF.

Later MTA will keep notifications for you - pertaining to jobs, someone assigned you, tasks needing approval, more.

Further down the road MTA will allow you to do integration with a host of ERP systems like Odoo, Acumatica, SAP Business One, more.

But for now - MTA is a simple time and attendance system that will allow you to keep track of your time, and material spent on jobs, and
allow you to bill your customers for the time your employees have spent on their projects, and materials used.

## REFERENCES

See [the references](REFERENCES.md) for a detailed list of all the contributors to open source that has 
had an impact on the realization of this product.

## Installation

Installing MTA on your local disk is only a matter of

```shell
$ git clone https://github.com/alco-company/mortimer-bellis.git
$ mv mortimer-bellis mortimer
$ cd mortimer
$ bundle
$ dev
```

You may spin up MTA on your local host with `debug` too - that will allow you to add `debugger` into the source where you need to.

Hit https://localhost:3000 in your browser - it will respect SSL.

## Configuration

First order of business is to configure your `config/database.yml` file to your setup.

Then there is the `config/credentials.yml.enc` file that you need to configure with your own credentials. You should issue this command
`rm config/credentials.yml.enc && rails credentials:edit` and add these lines:
  
  ```yaml
  secret_key_base: a10ng57r1ng0fch4r4c73r5
  microsoft:
    ad_id: m0r3ch4r4c73r5
    ad_secret: and50m3m0r3ch4r4c73r5
  ```

Rails will come up with the **secret_key_base** for you - you need to add the **microsoft** section with your own **ad_id** and **ad_secret**. You can get these from the Azure portal.

Most static host parameters, passwords, id's and API-keys are kept in `.env` which gets used for setting up deployment environments.
They are mentioned in `.kamal/a-template-4-secrets` file. You can copy that file to `.kamal/secrets` and edit it to your setup - perhaps even do a copy to `.kamal/secrets.staging` if you are going to deploy to a staging environment (in which case you'll have to edit the `config/deploy.staging.yml` ). In that case you should have a /.env.staging too. The 3 of them goes together like a pair of gloves: `.env, .kamal/secret, config/debug.yml`

## Deployment

Deploying MTA with [Kamal](https://kamal-deploy.org/) on a hosting platform like [Hetzner](https://hetzner.com) is
as easy as can be - use [this guide](https://dev.to/adrienpoly/deploying-a-rails-app-with-mrsk-on-hetzner-a-beginners-guide-39kp)
to assist you in the process and adjust the `config/deploy*.yml` files to your environment.

## Usage

Out of the box MTA will seed your database (it defaults to SQLite3 in the spirit of current Rails philosophy) with a
small dataset. All you have to do is sign up - with the first user being a 'superuser'

## Maintenance

### Data Backup

MTA has 3 levels of data persistence security

1. Versioning
2. Tenant focused backup
3. Database (multi-tenant) backup

**1. Versioning**
This level of security is yet to be implemented - but onoce implemented it will afford users to undo edits and deletes.

**2. Tenant focused backup**
This level of security is facilitated by running a background_job every so often. That stores a complete copy of all
tables and blobs (files uploaded by tenant users) in a tmp/tenant_:id_date/time.tar.gz that has a default retension of
7 days.

**3. Database (multi-tenant) backup**
The entire database is backup'ed up every morning at 1:01 UTC and the copy is placed off-site. This backup focuses on
the database tables/records - and not the blobs! That is to say that blobs are not copied at this level - and thus will
be lost if the entire MTA has to restore from a previous backup (which is not ideal)

it's handled by this crontab entry

`1 1 * * * /root/scripts/backup.rb >> /var/log/backup.log 2>&1`

calling this script

```
#!/usr/bin/env ruby

require 'net/sftp'

backup_filename = "production_#{Time.now.strftime('%Y%m%d_%H%M%S')}.sqlite3"
`cp /var/lib/docker/volumes/storage/_data/production.sqlite3 /root/backup_#{backup_filename}`

file=""
Net::SFTP.start(FTP_SERVER, FTP_USER, password: FTP_PASSWORD) do |sftp|
  local_path = "/root/backup_#{backup_filename}"
  remote_path = "#{OFFSITE_PATH}/#{backup_filename}"
  sftp.upload!(local_path, remote_path)
  sftp.dir.foreach(OFFSITE_PATH) do |entry|
    file = entry.longname if entry.longname =~ /#{backup_filename}/
  end
end
#
#
rsize = file.split(" ")[-5].to_i
lsize = `ls -la /root/backup_#{backup_filename}`.split(" ")[-5].to_i
if rsize == lsize
  `rm -f /root/backup_#{backup_filename}`
  puts "Backup of Docker5 (staging) /var/lib/docker/volumes/storage/_data/production.sqlite3 upload'et to #{FTP_SERVER}:#{OFFSITE_PATH}/#{backup_filename}"
end
```

CAVEAT: You might have to install _ruby_ on your box to run the script, `chmod +x /root/scripts/backup.rb`,
`touch /var/log/backup.log` and `chmod 666 /var/log/backup.log` - YMMV as the saying goes ;)

If the SQLite3 database is broken there's a fair chance `bin/fixsql` just might come through for you.
