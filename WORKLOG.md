# WORKLOG

## ROADMAP

* when we need a blogging engine - https://github.com/kuyio/bloak
* some day - down the road we will need measured - https://github.com/Shopify/measured
* make the move to XRB - https://socketry.github.io/xrb-rails/guides/getting-started/index
* endless scroll - https://www.stefanwienert.de/blog/2021/04/17/endless-scroll-with-turbo-streams/
* add litestream - https://fractaledmind.github.io/2024/04/15/sqlite-on-rails-the-how-and-why-of-optimal-performance/
* add handling of constants - https://dev.to/vladhilko/say-goodbye-to-messy-constants-a-new-approach-to-moving-constants-away-from-your-model-58i1
* add Traefik dashboard to traefik.mortimer.pro - https://www.luizkowalski.net/traefik-with-kamal-tips-and-tricks/
* add exporting ICS files - https://www.driftingruby.com/episodes/exporting-ics-files
* add employee SMS service - welcome, EU state report
* add blackhole
* add Stripe payments - https://gorails.com/episodes/one-time-payments-with-pay-and-stripe
* add employee email - welcome, EU state report
* gem "mission_control-jobs"
* add employee calendar - duty, free, holiday
* add web push notifications
* add Thruster - https://nts.strzibny.name/running-thruster-rails-kamal/
* gem fugit - more prominent substitute for CronTask
* make locale and time_zone selectable on sign_up
* release RC1
* big test
* make locale and time_zone select's
* add prettier mail layouts
* add state and EU state reporting - when?

## CHANGELOG

### 22/5/2024

* link to employee on punch_card list
* avoid to downgrade role on superuser
* make colors a concern
* fix missing complete url for punch_clocks used for QR code
* fix it for real

### 21/5/2024

* users/new - missing name
* add employee mugshot
* add user mugshot
* update employee.last_punched_at
* fix user_mugshot on regular/admin users
* allow admin to change account settings
* set location color as select
* set team color as select
* set account color as select
* error on color generation

### 20/5/2024

* make employees delete all punches today if they like
* show flashes with a component - proper styling
* place header button right
* do callbacks on punches

### 18/5/2024

* add boolean field format, forms and lists
* make payroll_employee_ident semi-optional - auto-generate if not set
  
### 17/5/2024

* add background job mgmt - wip
* list payroll_period punches on punch_clocks
* split of SQLite into writer/reader
* add CronTask for background jobs, more
* add queueable for background jobs
* setup solid_queue for offloading background jobs
* fix writer/reader issue with delete vs destroy
* add model.method association to form's
* add folded to contextmenu
* add error_report to user_mailer
* add punching_absence
* fix employees punching same state on multiple devices

### 16/5/2024

* adjust screen on employee app

### 15/5/2024

* add accounts.pdf
* add teams.pdf
* add users.pdf
* add locations.pdf
* add punch_clocks.pdf
* add employees.pdf
* add punch_cards.pdf
* add punches.pdf
* add split of SQLite into writer/reader
* send_file on PDFs from modal_controller

### 14/5/2024

* make teams and locations optional (add defaults when signing up)
* show only required fields on employee for a start
* move locale/time_zone to logo
* format on sign_in, more
* format header for indexes
* fix datalon export
* prepare for accounts persisting time to send reports
* try sending PDF report

### 13/5/2024

* add employee_state_job
* add employee_eu_state_job
* add build_pdf_job

### 11/5/2024

* setup container w/weasyprint and use httparty to consume 'PDF webservice'

### 10/5/2024

* fix employee's timezone on punches
* set time_zone right on POS controllers

### 8/5/2024

* add pos/employee - wip 3
* add pos/employee - delete one/all on the day
* add pos/employee - edit punches one by one
* add pos/employee - add free (hrs) & sick (days)

### 6/5/2024

* add pos/employee - wip 2

### 5/5/2024

* add pages - current roadmap
* add Redcarpet for Markdown
* allow admin of pages
* a few extensions to Redcarpet
* fix imported employees to have access_token and default state
* comment team state on form - for now
* add pos/employee - wip 1

### 4/5/2024

* mark m pink if superadmin
* add deleting all in background job
* allow superadmin to 'change' account
* allow superadmin to do global queries
* accounts cannot be queried on account_id
* user cannot become admin, admin cannot become superadmin
* some fancy listing of users + yields on text, date columns
* object count on accounts
* fix importing employees
* fix Teams being listed on other accounts
* fix Employees punching on other accounts

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
* missed a single payroll_employee_ident - in filter
* missed mort-flash-notice
* missed mort-flash-alert
* missing by_account on filters
* fix format (rubocop)

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
