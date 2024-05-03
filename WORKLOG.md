# WORKLOG

## ROADMAP

* endless scroll - https://www.stefanwienert.de/blog/2021/04/17/endless-scroll-with-turbo-streams/
* add litestream - https://fractaledmind.github.io/2024/04/15/sqlite-on-rails-the-how-and-why-of-optimal-performance/
* add handling of constants - https://dev.to/vladhilko/say-goodbye-to-messy-constants-a-new-approach-to-moving-constants-away-from-your-model-58i1
* add Traefik dashboard to traefik.mortimer.pro - https://www.luizkowalski.net/traefik-with-kamal-tips-and-tricks/
* add exporting ICS files - https://www.driftingruby.com/episodes/exporting-ics-files
* add blackhole
* add Stripe payments - https://gorails.com/episodes/one-time-payments-with-pay-and-stripe
* add web push notifications
* add mail report
* add EU state report
* add pos/employee

## CHANGELOG

### 3/5/2024

* refactor inheritance to base_controller
* refactor punch code
* delete_all item on contextmenu for lists
* add wage fields to teams and employees
* refactor punch_card recalculate
* fix import employee regression
* add pos/punch_clock
* missing filter on employees
* translate attributes on team and user
* add employee status views
* add links to employee status view on teams, employees
* refine translations for invitations, more
* translations and validations
* remove reader_schema.rb - not using AON

### 2/5/2024

* add invitable to user
* refactor default_scope to by_account
* refactor filter - redirects
* authorize accounts and users
* add name, more to user + edit profile
* remove skip_before... on modal_controller
* eager_load on production
* account not being set on models

### 1/5/2024

* add devise gem
* add user_mailer
* add label field css
* handle profile dropdown menu
* refactor filter on users
* implement Devise authentication
* add trackable, confirmable to user

### 30/4/2024

* add punches
* refactor CSV
* test touchstart on iPad - was SW update on iPad!
* don't show 'import' on contextmenu where it's not applied
* add export payroll data
* add account_mailer - lon_email
* fix unsupported argument_type PathName

### 29/4/2024

* add CSV import on every model - use employee as template
* prepare background jobs
* add solid_queue for offloading background jobs
* add punch_card
* add memory_logger - see config/initializers/memory_logger.rb
* postpone tests for now

### 26/4/2024

* bumped rails
* add console - `t` setting Current.account
* add CSV export on every model
* fix link CSS
* add modal
* add time_zoned - lookup module for time_zone field on models
* add upload field

### 25/4/2024

* added access_token for punch_clocks
* added filter to punch_clocks
* added SQLite3 performance enhancement gems
* add teams
* add date, datetime, time field formats - add-ons for superform
* add employees
* add punch_clocks to locations
* add employees to teams
* removed fingerprint - 04da67036737a473cae0e30551635be46588c707fe88c372fbe7518e99fe968b
* brakeman + rails test

### 24/4/2024

* add pagy for pagination
* refactor filtering
* deploy 12:47
* add development gems: dotenv-rails, amazing_print, rails_live_reload
* added a17t for default styled building blocks/components supporting TailwindCSS
* add rqrcode affording QR codes to easy distributing URLs for punch_clocks, more
* add location
* add punch_clock

### 23/4/2024

* https://guillaumebriday.fr/how-to-deploy-rails-with-kamal-and-ssl-certificate-on-vps to the rescue on setting up Letsencrypt
* add account
* add superform and lay foundation for views using Phlex
* make account tests green
* add I18n yml translations
* add filter
