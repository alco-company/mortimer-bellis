# WORKLOG

# fonts to use: Inter, Helvetica, Futura, Garamond, Times New Roman, Bodoni, Baskerville, Century Expanded
# <https://www.somanycode.com/awesome/awesome-ruby/> listing for many projects and gems

# all the samples for client features - https://github.com/GoogleChrome/samples/tree/gh-pages

## Rescue tools

## Ideas

https://anemone.mortimer.pro/oauth2/authorize?client_id=1&redirect_uri=https://anemone.mortimer.pro/oauth2/callback&response_type=code&scope=openid+profile+email+phone+address+roles+offline_access

https://anemone.mortimer.pro/oauth2/token
https://anemone.mortimer.pro/api/v1/contacts

https://nordhealth.design/templates/application/#


setup CI deployment with Kamal - https://www.rickpeyton.com/posts/step-by-step-guide-to-deploying-rails-8-with-kamal-and-github-actions-2
PWA: https://onrails.blog/2021/03/02/rails-pwas-using-turbo-hhnpwa-7/
NATIVE: https://blog.corsego.com/navigating-turbo-native, https://www.youtube.com/watch?v=TDQ2wtmgeKw
3CX: https://www.3cx.com/docs/crm-integration/

osascript = <<END
tell application "Messages"
  set targetBuddy to "#{phone_number}"
  set targetService to id of 1st account whose service whose service type = iMessage
  set theBuddy to participant targetBuddy of account id targetService
  set message to "#{message}"
  send message to theBuddy
end tell
END
`osascript -e '#{osascript}'`



## BUGS

* [ ] add breaks and included_in_duration to payroll_period#manual_punch
* [ ] redesign punch and add work_schedule to payroll_period#manual_punch
* fix error on employee_invitation#create -> returns turbo_frame in clear text - not HTML - at least on iPad
* <https://railsdesigner.com/preview-images-with-hotwire>

## CHANGELOG

* add customer has balance marker
{
  "Collection"=> [
   {"Number"=>22099, "ContactName"=>"SOPHUS FUGLSANG. EXPORT-MALTFABRIK A/S", "ContactGuid"=>"2e7bd2c1-761b-44e2-94be-d93151a45e13", "Date"=>"2024-11-01", "TotalExclVatInDkk"=>9494.4},
   {"Number"=>22098, "ContactName"=>"SILKEBORG SOGN MENIGHEDSRÅD", "ContactGuid"=>"f2f84fd5-853d-4420-9a8a-1531795a4adf", "Date"=>"2024-11-01", "TotalExclVatInDkk"=>450.0},
   {"Number"=>22097, "ContactName"=>"Nordthy A/S", "ContactGuid"=>"228f7848-1201-4034-aba9-ed18e3393542", "Date"=>"2024-11-01", "TotalExclVatInDkk"=>78075.0},
   {"Number"=>22096, "ContactName"=>"Nordthy A/S", "ContactGuid"=>"228f7848-1201-4034-aba9-ed18e3393542", "Date"=>"2024-11-01", "TotalExclVatInDkk"=>5400.0},
   ...
   {"Number"=>21936, "ContactName"=>"JON KATBORG ApS", "ContactGuid"=>"d7bc214e-719b-42ba-9125-664a6e2aff20", "Date"=>"2024-08-29", "TotalExclVatInDkk"=>225.0}
  ],
  "Pagination"=>{
    "MaxPageSizeAllowed"=>1000,
    "PageSize"=>500,
    "Result"=>26,
    "ResultWithoutFilter"=>26,
    "Page"=>0
  }
}

* make sidebar present like https://nordhealth.design/templates/application/#
* this is probably not necessary: format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@resource)) }
* pwa-installation.js + joy of rails
* consider https://bunny.net/ for image optimization and CDN as CloudFlare substitute
* pickup the mobile moving - ask if driving - enter odometer
* validate punches before deleting punch_clocks !!

## 16/12/2024

* modal for call - just a start
* slide forms and color backdrops
* test time input hh:mm
* second shot at time input
* second shot at time input II
* second shot at time input done
* stop the background from scrolling

## 12/12/2024

* deleting users - forwarding wrong email! farewell, not last_farewell
* clean-up signed_in_user
* initial DataDictionary - Presentation Definition Modeling - Page

## 11/12/2024

* customize doorkeeper views (later perhaps)
* open route to /calls
* don't show EntraID login on sign up
* clean up sign* views
* allow superadmin to delete tenants
* use remove on users too
* allow inviter to invite more invitees at a time

## 10/12/2024

* add contacts, and tickets to API
* fix missing time_spent on active t/m's
* first sketch for call's
* fix wrong layout on most record li elements
* update a few translations
* place setting infront of Punch Reminder
* testing 3CX integration

## 9/12/2024

* fix bug - when no account on t/m (or errornous account)
* add OAuth2.0 service provider (for future use - eg. native ) - and for other service integration (like 3CX)
* fix missing ErrorHandling

## 6/12/2024

* send notification to user - new task, session about to close, more
* notify user remember to punch in/out
* fix bugs in time_material - calc time and sort order date
* forgot a notifier

## 5/12/2024

* use over_time not overtime!!
* fix session information
* warn user if session nears end

## 4/12/2024

* refactore time_material - too much going on + InvoiceItemValidator
* forgot to enable ds.push_invoice
* very tiny bug - (t missing = nil)
* return correct value
* calc time and time_spent better
* make session last 7.days - and show it
* let the client logout by checking the session every 15 minutes

## 3/12/2024

* show price on time tasks
* show t/m date - not created_at
* set time spent to on global setting - either 0,25,50,75
* fix debugger
* fix resource()
* fix calc_time for time_material in invoice_draft

## 2/12/2024

* some devops work - making stuff easier
* start documenting with README.md
* if no product build one-off
* update time on active t/m's
* fix modal control close bug

## 1/12/2024

* band-aiding session timeout - not working - new plan later

## 30/11/2024

* more bug fixing - in the time/material form
* trying to stop the page refresh - when we cannot stop the scroll
* one more go at the scroll thing
* and another one
* bullet-proof solution
* test if geolocation works on mobile

## 29/11/2024

* polish all forms
* make allow notifications stick on client - for ever
* fix bug on enable_notifications on profile

## 28/11/2024

* huge issue with @hotwired/stimulus lost in importmap
* VAPID* missing in deploy.staging
* polish flash messages 2
* turbo_stream(later) virker kun med solid_queue's default async adapter i development!!
* make sessions last longer - 1 week (until Saturday Night)
* NoMethodError (undefined method `service_params_hash' SyncErpJob
* report back when user invited
* scroll the menu on mobile
* customers show up double in lookup?
* allow global_queries and tenant_swap (superuser)

### 26/11/2024

* get Kamal to deploy (again) - issues with ENV
* polish 2FA to work from dashboard view too
* polish punch_clocks
* polish settings
* polish background_jobs - add link to mission_control_jobs
* add error emails to default actions for better monitoring
* polish flash messages & toasts
* prepare for better background jobs - make recurring jobs actually run
* make running/paused jobs visibly easier on the eyes

### 25/11/2024

* add 2FA to user

### 21/11/2024

* bugs in registration_controller

### 20/11/2024

* add link affording escape from 400's & 500 error views
* make staging deployable too - might not be enough
* upgrade solid_queue to 1.0.2
* don't care about user pincode until confirmed
* lost the favicon - bring it back
* pulltorefreshjs - for mobile
* we need to instantiate the pulltorefresh on the page-controller
* try to get icons back on mobile
* tested svg's and the dinero callback revisited
* one more test on the buttons

### 19/11/2024

* upgrading SolidQueue to 0.8.0 - aiming for 1.0.0 further down the road
* trying to make config work for enhancedsqlite3-adapter
* going full Monty on upgrading Rails to 8.0.0 - and all gems

### 18/11/2024

* refactor mobilesidebar to animate
* refactor contextmenu & profilemenu to animate

### 15/11/2024

* add web notifications - take IV (web push)
* notification bell revisited
* hide scrollbars in document
* refactor notifications to use stimulus-use for animations

### 14/11/2024

* fix mugshot bug on user and tenant
* fix time_zone bug on teams and employees and punch_clocks
* add web notifications - take II
* try to fix add button on time_materials
* add web notifications - take III (web push)

* notification bell blocking >:(

### 13/11/2024

* place entra id login better
* identify search better + danish translations
* tighten up profile - in particular timezone select
* fix new time_material attributes bug
* fix km bug

### 12/11/2024

* add date on invoice_item comment - when work done
* add 50%/100% overtime
* add mileage accounting - at least invoicing mileage
* rename migrations to please Kamal!
* drop execute statements in migration
* dropped the entire thing - just added over_time
* big troubles - only getting 404's
* write "km" on list_items time_material when mileage
* fix name on list_item TimeMaterial - more

### 11/11/2024

* fix mugshot image size on uploads
* check service authentication on dinero - or reset it and tell!

### 08/11/2024

* allow argument on stage and prod scripts to backup databases
* bug on user/profile
* The kiosk provides visual confirmation (e.g., a success message) after a successful sign-in or sign-out.
* allow invoice_items with a_one_off item to be added to invoices - with defaultAccountNumber
* handle time_material_state on time_materials
* handle project_states on projects
* bug on invoice_draft - Dinero::Service
* bug in provided_services/dinero/service/_authorize

### 07/11/2024

* implementing naiive backup solution (scp to my desk)
* allow for stop/go to pause/resume easier
* inform about errors on input
* allow users to delegate jobs
* allow user to punch in/out on kiosks (punch_clocks)

### 06/11/2024

* add flash messages to omniauthable sign-ins
* add punching to dashboard view
* add user initials to invoiceable items
* handle set_order on missing models
* add kiosk link to form
* add pincode to users (and manage it)
* bug fixes on user and user_mailer
* trying to fix migration error in production
* trying to fix migration error in production II

### 05/11/2024

* refine stop/go button for time/material

### 04/11/2024

* show user img on list
* bug in listing grouped_by on index
* prepare sorting on resource_class - default by :name
* list punched_at
* notice how not to add time and material on one registration
* second stab at start/go button for time/material

### 01/11/2024

* testing better staging script
* add class[] and class.where_op(op, params) sugars
* add settings to allow users to see all t/m's
* fix bug on index.turbo_stream.erb - missing params and user

### 31/10/2024

* upgraded omniauthable to entra-id
* handling collapsible sidebar better
* stop/go knap til opsamling af forbrugt tid - WIP
* bug on omniauthable - dangling debugger statement
  
### 30/10/2024

* add icons to sidebar (navigation)
* allow sidebar to collapse + danish menu translation

### 29/10/2024

* fix showing invoiceable SVG/text when not invoiceable
* add omniauthable to sign_in - Microsoft Azure is first
* change layout for list_items on background_jobs, punch_clock
* show QR code on punch_clocks, state on background_jobs forms
* change layout on customers, dashboards, invoices, invoice_items, locations, products, projects, provided_services, punches, settings, teams, tenants, users
* hiding AD secrets

### 28/10/2024

* make sure redirects to signin reloads the page (issue with Turbo)
* allow for archive of time_materials
* start redesign list_items on lists - from LI to DIV
* add translations for missing elements
* fix wrong class name on Dinero::Service
* show association name when available
* by default show only user's own records (where applicable)
* fix bug in link to show_time_material
* fix layout in time_material form

### 25/10/2024

* add link to mortimer.pro/help
* add translation for uploading invoices
* don't repeat project name on invoice header
* infinity scroll on mobile - all over actually
* fulltext search on all models - NOT across all models
* tiny stab at 2FA - failed b/c Devise Two Factor Authentication is not compatible with Rails 8.0!

### 24/10/2024

* debugging dinero_upload
* projects -> separate invoice
* address -> multiple lines
* quantity/time -> not both
* icon on invoice_items

### 23/10/2024

* make group_by customizable on #index
* add settings to provided_services
* finish dinero_upload

### 22/10/2024

* make each line on /time_materials a component
* work on the dinero_upload (creating invoices)

### 21/10/2024

* add lookup for customers, projects, and products
* fix bug in lookup
* format t/m lines
* more bug fixing on t/m
* list t/m on /time_materials with day headers

### 18/10/2024

* now lookup works (at least for customers)
* testing numbers on ios
* continue working on the time_material form
* make color scheme and markup uniform
* set x v in bottom - like in top
* fix bug in views - t/m
* add upload button in t/m
* test how to create invoices

### 17/10/2024

* start with keyboard events on t/m
* fix bug on broadcastable/resource - drop broadcasting when resource is not persisted
* tell the world (or at least those listening) about the sync'ed resources (customers, products, invoices/invoice_items)
* build a lookup component for associations

### 16/10/2024

* the rest of forms - from background_jobs
* then customers
* forgot about the pdf's :o
* don't let t/m form 'skate'
* dashboards up next
* then invoice_items and invoices
* fast forward with kiosks (punch_clocks)
* and products and projects
* punches,
* and finally, provided_services, settings, teams, tenants, and users

### 15/10/2024

* fix bug on application layout - missing format on mobile
* make forms work with new drawer-style layout - and broadcasts
* locations first - next up: time & material - wip

### 14/10/2024

* list time_material on /time_materials
* bug on mobile topbar - not showing properly

### 10/10/2024

* add time_material model for persisting time and material draft input

### 9/10/2024

* EPIC 3 - manage invoices
* EPIC 3 - manage invoice_items
* missing filters on invoice and invoice_items
* EPIC 3 - time & material input

### 8/10/2024

* EPIC 3 - sync products from Dinero to Mortimer
* EPIC 3 - manage projects

### 7/10/2024

* EPIC 3 - sync customers from Dinero to Mortimer

### 1-3/10/2024

* adding Dinero API to Mortimer - affording integration with Dinero accounting system
* added provided_services
* bugfixing on provided_services
* setting ENV for staging on DINERO API
* fixing small errors all around after removing employees, more
* move entity show to right side - like edit
* missing authorize link on provided_services

### 30/9/2024

* keep going - making system tests green

### 26/9/2024

* more work on making tests green - now system tests work too, (or getting there)

### 25/9/2024

* rename employee to user
* remove around_action on ActionCable connection
* trying to get rename employee to user to work on migrations
* access Mortimer from iWatch - small test
* getting tests to work after last table and field adjustments - wip

### 23/9/2024

* make top menu extend to borders
* tell if no activity on dashboard
* make notifications h1 text-sm
* weaponize SidebarComponent - like render SidebarComponent.new(menu: {})
* make menu items on SidebarComponent visibly collapsible
* rotate sub_menu items on SidebarComponent - chevron-down
* move employee fields to user

### 22/9/2024

* add settings table
* add punch to the dashboard - wip
* rename account to tenant

### 21/9/2024

* add vertical menu in sidebar
* keep pagination to the right
* Kamal config validation has an issue with 'servers/web/options - should be a hash'

### 20/9/2024

* add locale pick to sign_up, sign_in, more
* first shot at work_schedule_templates UI
* force SSL in development and allow box.mortimer:3000
* show punch_button on user's dashboard

### 19/9/2024

* designing all views

--- intermezzo on bluebox ---

### 11/9/2024

* persist work_schedule_templates
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
