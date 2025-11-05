#
#
# t.integer "state", default: 0             draft active paused finished  pushed_to_erp error_on_push archived      default_state               fx 'draft'
#
# t.integer "tenant_id", null: false                                                                                Current.get_tenant
# t.integer "user_id", null: false                                                                                  | delegate_time_materials   true
#                                                                                                                   | Current.get_user.id
#
# t.string "date"                                                                                                   default_date                today
# t.string "time"
# t.datetime "paused_at"
# t.datetime "started_at"
# t.integer "time_spent"
# t.date "wdate"
# hour_time                                                                                                         default_hours               fx 0
# minute_time                                                                                                       default_minutes             fx 15
#
# t.string "about"                                                        |                                         default_time_material_about fx 'ongoing task'
# t.text "comment"                                                        |
#
# t.string "customer_name"                                                                                          add_customer
# t.string "customer_id"                                                  required
#
# t.string "project_name"                                                                                           add_project
# t.string "project_id"
#
# t.string "product_name"                                                 |                                         add_product
# t.string "product_id"                                                   | either
#
# t.string "quantity"                                                     required                                  default_quantity            fx 1
# t.string "rate"                                                         required                                  default_rate                fx 500.00
# t.integer "over_time", default: 0                                                                                 default_over_time           fx {base: 100, quarter: 125, fifty: 150, three_quarter: 175, 100percent:200} (%)
# t.string "discount"                                                     required                                  default_discount            fx 0.00
# t.string "unit_price"                                                   required
# t.string "unit"                                                         required

# t.string "pushed_erp_timestamp"
# t.string "erp_guid"
# t.text "push_log"

# t.boolean "is_invoice"
# t.boolean "is_free"
# t.boolean "is_offer"
# t.boolean "is_separate"

# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false

# currently not implemented
# t.integer "odo_from"
# t.integer "odo_to"
# t.integer "kilometers"
# t.string "trip_purpose"
# t.datetime "odo_from_time"
# t.datetime "odo_to_time"

#
# VALIDATIONS:
#
# validate_draft
# validate_active                       set_time_spent
# validate_paused                       set_time_spent
# validate_finished                     set_time_spent  finishable?
# validate_pushed_to_erp                                          pushable?
# validate_error_on_push
# validate_archived
#


class TimeMaterial < ApplicationRecord
  include Tenantable
  include Taggable
  include TimeMaterialStateable
  include Settingable
  include Unitable
  include Timing

  attr_accessor :calculated_unit_price

  belongs_to :customer, optional: true
  belongs_to :project, optional: true
  belongs_to :product, optional: true
  belongs_to :user

  # notifications
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"

  scope :by_fulltext, ->(query) { includes([ :customer, :project, :product ]).references([ :customers, :projects, :products ]).where("customers.name LIKE :query OR projects.name like :query or products.name like :query or products.product_number like :query or about LIKE :query OR product_name LIKE :query OR comment LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_about, ->(about) { where("about LIKE ?", "%#{about}%") if about.present? }
  scope :by_exact_user, ->(user) { where("user_id= ?", "%#{user.id}%") if user.present? }
  scope :weekdays, -> { where("cast(strftime('%w', wdate) as integer) BETWEEN 1 AND 5") }
  scope :billed, -> { where("is_invoice = ?", 1).where(state: [ :done, :pushed_to_erp ]) }
  scope :drafted, -> { where(state: [ :draft, :active, :paused ]) }
  scope :not_done_or_pushed, -> { where.not(state: [ states[:done], states[:pushed_to_erp] ]) }
  scope :by_state, ->(state) { where("state = ?", state) if state.present? }
  scope :by_customer, ->(customer) { where("customer_id = ?", customer.id) if customer.present? }
  scope :by_project, ->(project) { where("project_id = ?", project.id) if project.present? }
  scope :by_product, ->(product) { where("product_id = ?", product.id) if product.present? }
  scope :by_date, ->(date) { where("wdate = ?", date) if date.present? }
  scope :this_month, -> { by_tenant.where_op(:gt, created_at: Time.current.at_beginning_of_month) }
  scope :invoiceable, -> { by_tenant.where(is_invoice: true).where.not(customer_id: nil).where.not(state: states[:draft]) }

  def name
    # about
    case false
    when product_name.blank?; product_name
    when about.blank?; about
    when comment.blank?; comment
    else; user.default(:default_time_material_about, I18n.t("time_material.default_assigned_about"))
    end
  rescue
    ""
  end

  # STATS
  def self.total_time_registered
    h, m = this_month.sum(:registered_minutes).to_f.divmod(60)
    "%d,%02d" % [ (h rescue 0), (m / 60 * 100 rescue 0) ]
  end

  def self.avg_total_time_per_day
    h, m = (this_month.sum(:registered_minutes).to_f / weekdays_this_month rescue 0).divmod(60)
    "%d,%02d" % [ (h rescue 0), (m / 60 * 100 rescue 0) ]
  end

  def self.total_invoiceable_time
    h, m = invoiceable.this_month.sum(:registered_minutes).to_f.divmod(60)
    "%d,%02d" % [ (h rescue 0), (m / 60 * 100 rescue 0) ]
  end

  def self.avg_total_invoiceable_per_day
    h, m = (invoiceable.this_month.sum(:registered_minutes).to_f / weekdays_this_month rescue 0).divmod(60)
    "%d,%02d" % [ (h rescue 0), (m / 60 * 100 rescue 0) ]
  end

  def self.weekdays_this_month
    start_date = Time.current.at_beginning_of_month.to_date
    end_date = Time.current.to_date
    (start_date..end_date).select { |d| (1..5).include?(d.wday) }.count
  end

  def self.total_time_spent
    time_spent.sum(:time_spent)
  end

  def self.total_billed_time_spent
    billed.sum(:time_spent)
  end

  def self.average_time_per_day
    return 0 if count == 0
    (total_time_spent / count / 60.0).round(2)
  end

  def self.average_billed_time_per_day
    return 0 if billed.count == 0
    (total_billed_time_spent / billed.count / 60.0).round(2)
  end
  # --------


  # # SQLite
  # scope :weekdays_only, -> { where("strftime('%w', created_at) BETWEEN 1 AND 5") }

  # # PostgreSQL
  # scope :weekdays_only_in_timezone, ->(timezone) {
  #   where("EXTRACT(DOW FROM created_at AT TIME ZONE ?) BETWEEN 1 AND 5", timezone)
  # }
  # # MySQL
  # scope :weekdays_only, -> { where("DAYOFWEEK(created_at) BETWEEN 2 AND 6") }


  # validates :about, presence: true
  # validates :about, presence: true, if: [ Proc.new { |c| c.comment.blank? && c.product_name.blank? } ]
  # validates_with InvoiceItemValidator, on: :incoming_params

  before_save :set_wdate

  def set_wdate
    self.wdate = Date.parse date unless date.blank?
  end

  def has_insufficient_data?
    hid = false
    hid = true if project_name.present? && project_id.blank? && Current.get_user.cannot?(:add_projects)
    hid = true if customer_name.present? && customer_id.blank? && Current.get_user.cannot?(:add_customers)
    hid = true if product_name.present? && product_id.blank? && Current.get_user.cannot?(:add_products)
    hid = true if is_invoice? && customer_id.blank?
    hid
  rescue
    false
  end

  def initialize_new(hr = 0, dd = "")
    self.customer_name       = TimeMaterial.by_exact_user(Current.get_user).last&.customer_name
    self.state               = Current.get_user.default(:default_time_material_state, "draft")
    self.about               = Current.get_user.default(:default_time_material_about, "")
    self.hour_time           = Current.get_user.default(:default_time_material_hour_time, "")
    self.minute_time         = Current.get_user.default(:default_time_material_minute_time, "")
    self.rate                = hr
    # resource.over_time =      Current.user.default(:default_time_material_over_time, 0)
    self.date                = dd
    self.user_id             = Current.get_user.id
    self.started_at          = Time.current
    self.minutes_reloaded_at = Time.current
    self.registered_minutes  = 0
    self.time_spent          = 0
  end

  # def self.filtered(filter)
  #   flt = filter.collect_filters self
  #   flt = filter.filter

  #   all
  #     .by_tenant()
  #     .by_about(flt["about"])
  #     .by_state(flt["state"])
  # rescue
  #   filter.destroy if filter
  #   all
  # end

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      "time",
      # t.string "about"
      "customer_name",
      "customer_id",
      "project_name",
      "project_id",
      "product_name",
      "product_id",
      # t.string "quantity"
      # t.string "rate"
      # t.string "discount"
      # t.integer "state",
      # t.boolean "is_invoice"
      # t.boolean "is_free"
      # t.boolean "is_offer"
      # t.boolean "is_separate"
      "user_id",
      # t.text "comment"
      # t.string "unit_price"
      # t.string "unit"
      "pushed_erp_timestamp",
      "erp_guid",
      "push_log",
      # t.integer "time_spent"
      # t.integer "over_time",
      "odo_from",
      "odo_to",
      "kilometers",
      "trip_purpose",
      "odo_from_time",
      "odo_to_time"
    ]
    f = f + [
      "customer_name",
      "project_name",
      "product_name",
      "tag_list"
    ]
    f = f - [
      "date",
      "paused_at",
      "wdate",
      "created_at",
      "updated_at",
      "started_at"
      ] if model == self
    f
  end

  def self.user_scope(scope)
    case scope
    when "all"; nil # all.by_tenant()
    when "mine"; TimeMaterial.arel_table[:user_id].eq(Current.user.id)
    when "my_team"; TimeMaterial.arel_table[:user_id].in(Current.user.team.users.pluck(:id))
    end
  end

  def self.named_scope(scope)
    TimeMaterial.arel_table[:user_id].
    in(
      User.arel_table.project(:id).where(
        User[:name].matches("%#{scope}%").
        or(User[:team_id].in(Team.arel_table.project(:id).where(Team[:name].matches("%#{scope}%"))))
      )
    )
  end

  def csv_row(*fields)
    f = fields.dup
    f = f - [
      "customer_name",
      "project_name",
      "product_name",
      "tag_list"
    ]

    v = attributes.values_at(*f)
    v << self.customer&.name || "" if fields.include?("customer_name") # && self.customer.present?
    v << self.project&.name || "" if fields.include?("project_name") # && self.project.present?
    v << self.product&.name || "" if fields.include?("product_name") # && self.product.present?
    v << self.tag_list if fields.include?("tag_list")
    v
  rescue => e
    UserMailer.error_report(e.to_s, "TimeMaterial#csv_row - failed with params: #{fields}").deliver_later
    []
  end

  def self.associations
    [ [ Customer, Project, Product ], [] ]
  end

  def self.set_order(resources, field = :wdate, direction = :desc)
    resources.ordered(field, direction).order(created_at: :desc)
  end

  def remove(step = nil)
    self.taggings.each { |t| t.destroy! }
    destroy!
  end

  def list_item(links: [], context:, user: nil)
    TimeMaterialDetailItem.new(item: self, links: links, id: context.dom_id(self), user: user)
  end

  def notify(action: nil, title: nil, msg: nil, rcp: nil, priority: 0)
    return if user_id.blank? && rcp.blank?

    if user_id != Current.user.id
      msg = case action
      when :create; I18n.t("time_material.new_assigned_task", delegator: Current.user.name)
      when :update; I18n.t("time_material.updated_assigned_task", moderator: Current.user.name)
      when :destroy; I18n.t("time_material.destroyed_assigned_task", terminator: Current.user.name)
      else
        msg ||= I18n.t("time_material.assigned_task", transmittor: Current.user.name)
      end
      title = title || about || product_name || comment || I18n.t("notifiers.no_title")
      TimeMaterialNotifier.with(record: self, current_user: Current.user, title: title, message: msg, delegator: Current.user.name).deliver(user)
      TimeMaterialNotifier.with(record: self, current_user: Current.user, title: title, message: msg, delegator: Current.user.name).deliver(rcp) unless rcp.blank?
    end
  end

  def has_mugshot?
    false
  end

  def is_time?
    product_id.blank? && product_name.blank?
  end

  def self.form(resource:, editable: true)
    TimeMaterials::Form.new resource: resource, editable: editable
  end

  def self.overtimes
    [
      [ 0, I18n.t("time_material.overtimes.none") ],
      [ 1, I18n.t("time_material.overtimes.50percent") ],
      [ 2, I18n.t("time_material.overtimes.100percent") ]
    ]
  end

  def self.overtimes_products
    h = []
    Current.get_user.tenant.time_products.each do |p|
      h << p.base_amount_value.to_s
    end
    h.to_json
  end

  def self.trip_purposes
    [
      [ "service", I18n.t("time_material.trip_purposes.service") ],
      [ "delivery", I18n.t("time_material.trip_purposes.delivery") ],
      [ "pickup", I18n.t("time_material.trip_purposes.pickup") ]
    ]
  end

  #
  # make sure this record is good for pushing to the ERP
  #
  def pushable?(resource_params)
    shadow_tm = self.dup
    permitted = resource_params
    shadow_tm.assign_attributes(permitted)
    entry = InvoiceItemValidator.new(shadow_tm, user)
    return true if entry.valid?
    self.project = entry.project if entry.project.present?
    self.errors.add(:base, entry.errors.full_messages.join(", "))
    false
    # if resource.quantity.blank?
    #   raise "mileage_wrong" if is_invoice? and !kilometers.blank? and is_mileage_wrong?(resource)
    #   raise "quantity not correct format" if (time =~ /^\d*[:,.]?\d*$/).nil? and comment.blank?
    #   raise "rate not correct format" if !rate.blank? and (rate =~ /^\d*[,.]?\d*$/).nil? and comment.blank?
    #   raise "time and quantity and mileage cannot all be blank" if time.blank? and comment.blank? and kilometers.blank?
    #   raise "time not correct format" if !time.blank? and (time =~ /^\d*[:,.]?\d*$/).nil?
    # else
    #   raise "time, quantity, kilometers - only one can be set" if !time.blank? or !kilometers.blank?
    #   raise "rate cannot be set if product and quantity is set!" if !rate.blank? && !product_id.blank?
    #   raise "product_name cannot be blank if quantity is not blank!" if product_name.blank?          # with one off's we use the product text as description! No need to check product.name   # check if product exists/association set correctly
    #   raise "quantity not correct format" if (quantity =~ /^\d*[:,.]?\d*$/).nil?
    #   raise "unit_price not correct format" if !unit_price.blank? && (unit_price =~ /^\d*[,.]?\d*$/).nil?
    #   raise "discount not correct format" if !discount.blank? && (discount =~ /^\d*[,.]?\d*[ ]*%?$/).nil?
    #   raise "not service, product, or text - what is this?" if product.nil? && product_name.blank? && comment.blank?
    # end
    # # we'll use the project field for adding a comment in the top of the invoice
    # # or use the project.name !resource.project_name.blank? && resource.project.name
    # true
  end


  def prepare_tm(resource_params)
    # if product/material
    if resource_params[:product_name].present? or resource_params[:product_id].present?
      resource_params[:hour_time] = ""
      resource_params[:time] = ""
      resource_params[:minute_time] = ""
      self.time = ""
      self.hour_time = ""
      self.minute_time = ""
      self.rate = ""
      resource_params[:rate] = ""
      resource_params[:over_time] = ""
      self.over_time = 0
      self.time_spent = 0
    end
    if resource_params[:state].present? &&
      resource_params[:state] == "done"

      resource_params = create_customer(resource_params)
      resource_params = create_project(resource_params)
      if Current.get_user.should?(:validate_time_material_done)
        if resource_params[:discount].present?
          resource_params[:discount] = case resource_params[:discount]
          when "0"; ""
          when "0%"; 0
          when "100%"; 100
          when /%/; resource_params[:discount].to_s.delete("%").gsub(",", ".").to_f
          else resource_params[:discount].gsub(",", ".").to_f
          end
        end

        if resource_params[:played].present?
          resource_params.delete(:played)
          return true
        end
        unless pushable?(resource_params)
          errors.add(:base, errors.full_messages.join(", "))
          return false
        end
        return false unless valid?
      end
    end
    resource_params
  rescue => e
    # debug-ger
    UserMailer.error_report(e.to_s, "TimeMaterial#prepare_tm - failed with params: #{resource_params}").deliver_later
    false
  end

  def create_customer(resource_params)
    resource_params[:customer_id] = "" if resource_params[:customer_name].blank?
    return resource_params unless Current.get_user.can?(:add_customers, resource: self)


    if (resource_params[:customer_id].present? && (Customer.find(resource_params[:customer_id]).name != resource_params[:customer_name])) ||
      resource_params[:customer_name].present? && resource_params[:customer_id].blank?
      customer = Customer.find_or_create_by(tenant: Current.get_tenant, name: resource_params[:customer_name], is_person: true, country_key: "DK")
      resource_params[:customer_id] = customer.id
    end
    resource_params
  end

  def create_project(resource_params)
    resource_params[:project_id] = "" if resource_params[:project_name].blank?
    return resource_params unless Current.get_user.can?(:add_project, resource: self)

    if (resource_params[:project_id].present? && (Project.find(resource_params[:project_id]).name != resource_params[:project_name])) ||
      resource_params[:project_name].present? && resource_params[:project_id].blank?
      project = Project.find_or_create_by(tenant: Current.get_tenant, name: resource_params[:project_name], customer_id: resource_params[:customer_id])
      resource_params[:project_id] = project.id
    end
    resource_params
  end
end
