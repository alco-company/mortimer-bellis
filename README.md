# README

Mortimer Time & Attendance (MTA) is _your fastest from job done to invoice sent_. You get a back office
with tenants, users, locations, teams, projects, more, and you get a _front office_ with
time_material and exporting to CSV, and later PDF.

Later MTA will keep notifications for you - pertaining to jobs, someone assigned you, tasks needing approval, more.

Further down the road MTA will allow you to do integration with a host of ERP systems like Odoo, Acumatica, SAP Business One, more.

But for now - MTA is a simple time and attendance system that will allow you to keep track of your time, and material spent on jobs, and
allow you to bill your customers for the time your employees have spent on their projects, and materials used.

## REFERENCES

See [the references](REFERENCES.md) for a detailed list of all the contributors to open source that has had an impact on the
realization of this product.

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

There are 2 shell scripts in the `bin` directory that you can use to maintain your MTA installation. The `bin/backup_dev` script
will backup your development database to a file in the `db` directory. The `bin/backup_prod` will do the same for your production. 

Please note that both scripts are cut to measure - you most likely will have to adjust them to your environment!

If the SQLite3 database is broken there's a fair chance `bin/fixsql` just might come through for you.
