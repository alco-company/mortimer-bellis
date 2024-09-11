# WORKLOG

# fonts to use: Inter, Helvetica, Futura, Garamond, Times New Roman, Bodoni, Baskerville, Century Expanded
# <https://www.somanycode.com/awesome/awesome-ruby/> listing for many projects and gems

## Rescue tools

* How to rescue your SQLite database - https://support.storj.io/hc/en-us/articles/360029309111-How-to-fix-a-database-disk-image-is-malformed

```bash
?1 storage % sqlite3 development.sqlite3   
SQLite version 3.43.2 2023-10-10 13:08:14
Enter ".help" for usage hints.
sqlite> .mode insert
sqlite> .output dump_all.sql
sqlite> .dump
sqlite> .exit
√ storage % sqlite3 development.sqlite3 ".mode insert; .output dump_all.sql; .dump;"
√ storage % { echo "PRAGMA synchronous = OFF ;"; cat dump_all.sql; } | grep -v -e TRANSACTION -e ROLLBACK -e COMMIT >dump_all_notrans.sql 
√ storage % mv development.sqlite3 corrupted_23_8_2024.development.sqlite3
√ storage % sqlite3 development.sqlite3 ".read dump_all_notrans.sql"
√ storage % sqlite3 development.sqlite3 "PRAGMA integrity_check;"                                                                        
ok

```

If Solid Queue bites me again, look here: https://github.com/rails/solid_queue/issues/309:

## Ideas

### Guide for new users

1. build a list of necessary guide tips
2. add tips_progress on the user
3. allow user to skip further tips => set tips_progress to 1000
4. on every 5th request, show a tip until user tips_progress is 10, then 10ths until 100, then 20ths until 200, then 50ths until 500, then 100ths until 1000
5. allow sign_up in multiple languages
6. build a native app - <https://blog.corsego.com/navigating-turbo-native> / <https://www.youtube.com/watch?v=TDQ2wtmgeKw>

## BUGS

* [ ] add breaks and included_in_duration to payroll_period#manual_punch
* [ ] redesign punch and add work_schedule to payroll_period#manual_punch
* fix error on employee_invitation#create -> returns turbo_frame in clear text - not HTML - at least on iPad
* <https://railsdesigner.com/preview-images-with-hotwire>

## CHANGELOG

### 11/9/2024

* show work-template - wip II

### 10/9/2024

* show calendar name
* show work-template - wip

### 9/9/2024

* color calendars on account, team, employee

### 5/9/2024

* small typo fixed on dividing with 60

### 3/9/2024

* stats on landing page - wip
* fix small error on processing punches
* finish landing page - v1

### 2/9/2024

* allow free and sick punches for the day
* move invite to users
* fresh landing page - welcoming new users - wip

### 30/8/2024

* fix yet another Current.account issue - set_resources_stream
* overscroll-contain on edit.html and new.html
* fix layout on main and index and new/edit/show

### 29/8/2024

* add bin/fixsql to fix SQLite database
* mark notifications as read
* send notification to (super)admin when new employee signs up
* show notifications as dropdown
* fix bug on application.html.erb - missing check for Current.user
* fix bug on set_resources_stream - missing check for Current.account

### 27/8/2024

* first stab at system testing with login
* reduce object generation when logging

### 26/8/2024

* work on general turbo_stream model CRUD methods

### 23/8/2024

* fix error on holidays filter

### 22/8/2024

* add noticed gem for sending notifications - wip

### 21/8/2024

* fix background_jobs - solid queue issues
* put punch methods in their place

### 20/8/2024

* work on background jobs - solid queue issues - wip

### 19/8/2024

* fix show events when none present
* fix misssing add button on day_summary
* drop header on calendars/:id
* fix non-working menuitems on 'more' on calendars/:id in mobile view
* show events spanning multiple days
* show [whimsical](https://whimsical.com/pos-RGjYYm84RR3pbF4fL5XUzU) POS punch options

### 16/8/2024

* list punches on calendar views
  
### 15/8/2024

* fix regression on delete/delete_all II
* disable delete_all when no records
* link to list of calendars on team and employees and accounts

### 14/8/2024

* fix regression on delete/delete_all
* edit events on day and week view
* finish day_summary - wip

### 13/8/2024

* show events on week view
* show events on day view - wip

### 12/8/2024

* show events on month view II
* prepare for HTTP/2 - add httpx

### 9/8/2024

* persist most of event and event_metum
* show events on month view

### 8/8/2024

* remove log error `Unpermitted parameter: :url.`

### 7/8/2024

* send mail after completing sign_up (employee)
* persist most recurring event meta data

### 6/8/2024

* add ?lang=da to sign_up path

### 20/7/2024

* working on event save

### 15-20/7/2024

* add event model

### 9-14/7/2024

* add input form for events

### 8/7/2024

* work on week view on calendar - wip

### 6/7/2024

* show week view on calendar
  
### 4/7/2024

* build on events_list component - wip
* add month view on calendar
* show events on calendar - below month view

### 3/7/2024

* build day summary
* add holiday scaffold
* [ ] add country to account, team, employee - to show proper holidays

### 2/7/2024

* link to day view on year calendar

### 1/7/2024

* add a calendar table to account, team, and employee

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
* advice on new 'lead' on accounts to <walther@alco.dk>

### 19/6/2024

* change ringcolor to ring-sky-600 on input fields
* trying to signup with <user@existing.domain> does not work - if no users exist!
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
* fix <ActiveRecord::ReadOnlyError: Write query attempted while in readonly mode: UPDATE..> - perhaps use: <https://blog.saeloun.com/2023/12/06/rails-dual-database-setup/>
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

* <https://guillaumebriday.fr/how-to-deploy-rails-with-kamal-and-ssl-certificate-on-vps> to the rescue on setting up Letsencrypt
* add account
* add superform and lay foundation for views using Phlex
* make account tests green
* add I18n yml translations
* add filter
