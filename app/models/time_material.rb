#
#
# Transition TimeMaterial
#
# 1. add defaults (implement using settings)
# 2. add validations depending upon state
# 3. add conversion table - -
#
# state                         draft   active  paused  finished  pushed_to_erp   error_on_push   archived        default_state             fx 'draft'
#
# FIELDS:
#
# date                                                  x
# user_id                                               x                                                         delegate_time_materials   true
# about                                                                                                           default_about             'ongoing task'
# hour_time                             s               x                                                         default_hours             0
# minute_time                           s               x                                                         default_minutes           fx 15
# rate                                                  x                                                         default_rate              fx 500.00
# over_time                                             x                                                         default_over_time         fx {base: 100, quarter: 125, fifty: 150, three_quarter: 175, 100percent:200} (%)
#
#
# product_id                                            x         y                                               allow_create_product
# comment
# quantity                                              x         y
# unit                                                  x         y
# unit_price                                            x         y
# discount
#
# customer_name                                         x                                                         allow_create_customer
# customer_id                                           x         y
# project_name                                          x                                                         allow_create_project
# project_id                                            x
#
# is_invoice                  [ 'y', 'n' ]
# is_separate                 [ 'y', 'n' ]

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
  include TimeMaterialStateable
  include Settingable
  include Unitable

  attr_accessor :hour_time, :minute_time

  belongs_to :customer, optional: true
  belongs_to :project, optional: true
  belongs_to :product, optional: true
  belongs_to :user

  # notifications
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"

  scope :by_fulltext, ->(query) { includes([ :customer, :project, :product ]).references([ :customers, :projects, :products ]).where("customers.name LIKE :query OR projects.name like :query or products.name like :query or products.product_number like :query or about LIKE :query OR product_name LIKE :query OR comment LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_about, ->(about) { where("about LIKE ?", "%#{about}%") if about.present? }
  scope :by_exact_user, ->(user) { where("user_id= ?", "%#{user.id}%") if user.present? }
  scope :weekdays, -> { where("cast(strftime('%w', date) as integer) BETWEEN 1 AND 5") }

  # # PostgreSQL
  # scope :weekdays_only_in_timezone, ->(timezone) {
  #   where("EXTRACT(DOW FROM created_at AT TIME ZONE ?) BETWEEN 1 AND 5", timezone)
  # }
  # # MySQL
  # scope :weekdays_only, -> { where("DAYOFWEEK(created_at) BETWEEN 2 AND 6") }


  # validates :about, presence: true

  # validates :about, presence: true, if: [ Proc.new { |c| c.comment.blank? && c.product_name.blank? } ]

  before_save :set_wdate

  def set_wdate
    self.wdate = Date.parse date unless date.blank?
  end

  def has_insufficient_data?
    (project_name.present? && project_id.blank?) ||
    (customer_name.present? && customer_id.blank?) ||
    (product_name.present? && product_id.blank?)
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

  def self.associations
    [ [ Customer, Project, Product ], [] ]
  end

  def self.set_order(resources, field = :date, direction = :desc)
    resources.ordered(field, direction)
  end

  def list_item(links: [], context:)
    TimeMaterialDetailItem.new(item: self, links: links, id: context.dom_id(self))
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

  def name
    about
    case false
    when product_name.blank?; product_name
    when about.blank?; about
    when comment.blank?; comment
    else; Current.user.default(:default_time_material_about, "ongoing task")
    end
  end

  def hour_time
    return "" if self.time.blank?
    return self.time.split(":")[0] if self.time.include?(":")
    return self.time.split(",")[0] if self.time.include?(",")
    return self.time.split(".")[0] if self.time.include?(".")
    time
  end

  def hour_time=(val)
    return if val.blank?
    self.time = "#{val}:00" if self.time.blank?
    self.time = "%s:%s" % [ val, self.time.split(":")[1] ] if self.time.include?(":")
    self.time = "%s:%s" % [ val, self.time.split(",")[1] ] if self.time.include?(",")
    self.time = "%s:%s" % [ val, self.time.split(".")[1] ] if self.time.include?(".")
  end

  def minute_time
    return "" if self.time.blank?
    return self.time.split(":")[1] if self.time.include?(":")
    return self.time.split(",")[1] if self.time.include?(",")
    return self.time.split(".")[1] if self.time.include?(".")
    time
  end

  def minute_time=(val)
    return if val.blank?
    self.time = "00:#{val}" if self.time.blank?
    self.time = "%s:%s" % [ self.time.split(":")[0], val ] if self.time.include?(":")
    self.time = "%s:%s" % [ self.time.split(",")[0], val ] if self.time.include?(",")
    self.time = "%s:%s" % [ self.time.split(".")[0], val ] if self.time.include?(".")
  end

  def has_mugshot?
    false
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

  def self.trip_purposes
    [
      [ "service", I18n.t("time_material.trip_purposes.service") ],
      [ "delivery", I18n.t("time_material.trip_purposes.delivery") ],
      [ "pickup", I18n.t("time_material.trip_purposes.pickup") ]
    ]
  end

  def calc_hrs_minutes(t)
      days, hours = t.to_i.divmod 86400
      hours, minutes = hours.divmod 3600
      minutes, seconds = minutes.divmod 60
      [ days, hours, minutes, seconds ]
  end

  #
  # return time as a decimal number
  # eg 1:30 => 1.5
  #
  def calc_time_to_decimal(t = nil)
    t ||= time
    return 0.25 if t.blank?
    return t if t.is_a?(Numeric)
    t = if t.include?(":")
      h, m = t.split(":")
      m = (m.to_i*100.0/60.0).to_f.round
      "%s.%i" % [ h, m ]
    else
      t = t.split(",") if t.include?(",")
      t = t.split(".") if t.include?(".")
      if t.is_a? Array
        "%s.%i" % [ t[0], t[1] ]
      else
        t
      end
    end
  end

  # def sanitize_time_spent
  #   split_time(time_spent, true)
  # end

  # first make sure time is a number -
  # ie if it's a string with 1.25 or 1,25 or 1:25 reformat it
  # then calculate the hours and minutes from the time integer
  # if the resource should be limited to quarters, then round up the minutes to the nearest quarter
  # finally return the hours and minutes as a string with a colon
  #
  def sanitize_time(ht, mt)
    ptime = set_ptime ht, mt
    # return "" if ptime.blank? or ptime.gsub(/[,.:]/, "").to_i == 0
    t = ptime.split(":")
    minutes = t[0].to_i*60 + t[1].to_i
    # minutes = case true
    # when ptime.to_s.include?(":"); t = ptime.split(":"); t[1]=t[1].to_i*10 if t[1].size==1; t[0].to_i*60 + t[1].to_i
    #   # when ptime.to_s.include?(":"); t = ptime.split(":"); t[1]=t[1].to_i*10 if t[1].size==1; t[0].to_i*60 + t[1].to_i
    #   # when ptime.to_s.include?(","); t = ptime.split(","); t[1]=t[1].to_i*10 if t[1].size==1; t[0].to_i*60 + t[1].to_i*60/100
    #   # when ptime.to_s.include?("."); t = ptime.split("."); t[1]=t[1].to_i*10 if t[1].size==1; t[0].to_i*60 + t[1].to_i*60/100
    #   # else ptime.to_i * 60
    # end
    hours, minutes = minutes.divmod 60
    if should?(:limit_time_to_quarters) # && !ptime.include?(":")
      minutes = case minutes
      when 0; 0
      when 1..15; 15
      when 16..30; 30
      when 31..45; 45
      else hours += 1; 0
      end
    end
    "%02d:%02d" % [ hours.to_i, minutes.to_i ] rescue "00:00"
  end

  def set_ptime(ht, mt)
    self.hour_time=ht
    self.minute_time=mt
    self.time
  end

  # def split_time(time, minutes)
  #   if minutes
  #     d, h, m, _s = calc_hrs_minutes(time)
  #     time = d * 24 * 60 + h * 60 + m
  #     time = time.divmod 60
  #   else
  #     time = case true
  #     when resource_params[:time].present? && resource_params[:time].include?(","); resource_params[:time].split(",")
  #     when resource_params[:time].present? && resource_params[:time].include?("."); resource_params[:time].split(".")
  #     else [ time, "0" ]
  #     end
  #     time[0] = time[0].blank? ? "0" : time[0].to_s
  #     time[1] = (time[1].to_i*60.0/100.0).to_i if time.is_a? Array
  #   end
  #   time
  # rescue
  #   time
  # end

  #
  # make sure this record is good for pushing to the ERP
  #
  def values_ready_for_push?
    entry = InvoiceItemValidator.new(self)
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
    if resource_params[:state].present? &&
      resource_params[:state] == "done" &&
      Current.user.default(:validate_time_material_done, true) == "true"

      if resource_params[:played].present?
        resource_params.delete(:played)
        return true
      end
      unless values_ready_for_push?
        errors.add(:base, errors.full_messages.join(", "))
        return false
      end
      valid?
    else
      true
    end
  rescue => e
    # debug-ger
    UserMailer.error_report(e.to_s, "TimeMaterial#prepare_tm - failed with params: #{resource_params}").deliver_later
    false
  end
end
