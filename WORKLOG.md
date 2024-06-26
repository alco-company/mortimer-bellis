# WORKLOG

## BUGS

* [ ] add breaks and included_in_duration to payroll_period#manual_punch
* [ ] redesign punch and add work_schedule to payroll_period#manual_punch

## CHANGELOG

### 28/6/2024

* [ ] activate x on toasts
* [ ] show weekday name on pos/employees#payroll_period
* [ ] add excluded_days to payroll_period#manual_punch
* [ ] add start_time and end_time and duration to payroll_period#manual_punch

### 27/6/2024

* send confirmed email users to the root_path
* [ ] model.team.blocked error on employees/new
* [ ] confirmation email for new account first user
* [ ] welcome email to new employees - imported ones
* [ ] try out lang=da on html tag
* [ ] fix error on punch_card.recalculate when sick or free

### 26/6/2024

* first stab at schedules: days
* wrong toast on profile update - should be success
* mail on new account added by us

### 25/6/2024

* tooltip on punch#comment
* hide empty flash messages "{}"
* fix wrong link on pos/punch_clock payroll_period list close elements
* remove indigo-500 from input fields
* move flash on mobile view up 10px
* use BooleanField on team#blocked_from_punching and block punching on employee
* refine danish localisation for employee and team
* fix params permissions
* show account when global_queries
* forgot to show navn in any case !!"#€!
* show version & locale and time_zone on profile only
  
### 24/6/2024

* fix missing sort by punch_clock on punches

### 23/6/2024

* prepare for hotwired flash messages (and later notifications)
* prepare for tooltips - wip: turbo_frame not loading!


### 21/6/2024

* archive employees once they off-board (or only work as temps)
* bug in test for archived? if no punches
* use ADD button as SAVE too on pos/employee
* show comment icon on punches where applicable

### 20/6/2024

* mail format on password_change & email_changed touch up
* advice on new 'lead' on accounts to walther@alco.dk

### 19/6/2024

* change ringcolor to ring-sky-600 on input fields
* trying to signup with user@existing.domain does not work - if no users exist!
* show ID on accounts, and add tax_number
* css error 700-400
* fix mail formats - prettier mails and views for Devise
* add lockable w/5 attempts to Devise
* place sign_in in :writer ActiveRecord connection
* trying to avoid: Net::SMTPServerBusy (450 4.1.2 <waboo@wabidu.dk>: Recipient address rejected: Domain not found

### 18/6/2024

* add prettier mail layouts

### 17/6/2024

* make 'traefik' answer to ur.alco.company
* make 'traefik' not answer to ur.alco.company - but app.mortimer.pro
* make the app list as 'app.mortimer.pro'
* proper favicon - wip
* work on translations
* fix favicon

### 16/6/2024

* fix error on sum_punches - when across midnight
* brakeman - ignore false positives
* format code - rubocop -a
  
### 14/6/2024

* (undefined method `[]' for nil:NilClass) - punch_clock_base:50
* allow employee to close day listing (payroll_period)
* translate menu on pos/employee
* fix timing issue on punch_card.recalculate

### 13/6/2024

* add stats on payroll_period (like today)
* add work_minutes today on payroll_period
* perfect the UI on pos/employee (some)

### 12/6/2024

* fix "(No route matches [PUT] "/pos/employee")"
* fix discrepancy in Time.parse - use Time.zone.parse
* authorize users on accounts, pages, and users
* format invitation/edit - Du er blevet inviteret af navn, ALCO
* suggest time_zone to user and employee

### 11/6/2024

* allow employees to delete their mugshots
* fixing wrong loading of config/locales
* show confetti on user sign up complete
* fix error on saving changes to punch by employee
* employee - show spent time on payroll_period
* send first punch success email - w/links to attach app to home screen (iPhone & Android)

### 10/6/2024

* add dashboards to accounts destroy action
* show confetti on employee sign up complete
* fix missing punch_cards on employee's list of punches
* fix missing filters when deleting :all
* allow for argument to by_account()
* allow employee to set locale and time_zone on profile
* make header fixed - not sticky
  
### 9/6/2024

* solve error on punching with no contract_minutes set
* make first punch_clock the employee's own device
* handle error on deleting (account)

### 8/6/2024

* allow admin to invite employee

### 7/6/2024

### 4/6/2024

* allow delete photo - account, user, employee

### 3/6/2024

* add comments on manual punches (and on edit)
* fix missing entries in payroll_punches (missing on smartphone only)
* add context items to show on accounts, teams, locations, employees, punch_clocks, punch_cards
* move <remote-modal-container> to layout
* show 'badge' on punch_cards where "cannot compute"
* show only select elements current to account
* allow delete logo

### 31/5/2024

* add delete modal
* fix timezone issue when incorrect zone

### 29/5/2024

* passed an object to plain that is not handled by format_object
* change use of console enhancements to use IRB::Command API
* point to proper PDF service host
* only run console extension in development
* drop console extension
* set time_zone = creators on create employee
* show h:m on updated_at on punch
* 'ret' = 'gem' when saving edit on punch
* fix <ActiveRecord::ReadOnlyError: Write query attempted while in readonly mode: UPDATE..> - perhaps use: https://blog.saeloun.com/2023/12/06/rails-dual-database-setup/
* link on punch err's

### 28/5/2024

* locale, time_zone = same as creator on create employee
* locale, time_zone = same as creator on create user
* punches on tablets - payroll_period - cannot list all
* add staging server - anemone.mortimer.pro - and scripts stage and prod
* undefined method `format_date' for #<DateColumn

### 27/5/2024

* prettier file input
* add dashboard - fix home = today
* fix listing punches in pos/employee in correct timezone
  
### 24/5/2024

* handle view_only for account_id and user_id
* add /background_jobs listing
* enable rails live reload
* fix bad URL to employee on /punches
* fix punch form - make state selectable

### 23/5/2024

* make time_zone select's
* show work_time / break_time stats
* show todays punches on pos/employee
* show payroll_period punches on pos/employee
* fix edit punches on pos/employee

### 22/5/2024

* link to employee on punch_card list
* avoid to downgrade role on superuser
* make colors a concern
* fix missing complete url for punch_clocks used for QR code
* fix it for real
* make lists sortable - ?s=column_name&d=asc
* make locale and time_zone select's

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
