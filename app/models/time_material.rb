class TimeMaterial < ApplicationRecord
  include Tenantable
  include TimeMaterialStateable
  include Settingable

  belongs_to :customer, optional: true
  belongs_to :project, optional: true
  belongs_to :product, optional: true
  belongs_to :user

  scope :by_fulltext, ->(query) { includes([ :customer, :project, :product ]).references([ :customers, :projects, :products ]).where("customers.name LIKE :query OR projects.name like :query or products.name like :query or products.product_number like :query or about LIKE :query OR product_name LIKE :query OR comment LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_about, ->(about) { where("about LIKE ?", "%#{about}%") if about.present? }
  scope :by_exact_user, ->(user) { where("user_id= ?", "%#{user.id}%") if user.present? }

  # validates :about, presence: true

  validates :about, presence: true, if: [ Proc.new { |c| c.comment.blank? && c.product_name.blank? } ]

  def self.set_order(resources, field = :created_at, direction = :desc)
    resources.ordered(field, direction)
  end

  def list_item(links: [], context:)
    TimeMaterialDetailItem.new(item: self, links: links, id: context.dom_id(self))
  end

  def notify(msg: nil, rcp: nil, priority: 0)
    if user_id != Current.user.id
      TimeMaterialNotifier.with(record: self, current_user: Current.user, message: I18n.t("time_material.new_assigned_task", delegator: Current.user.name)).deliver(user)
    end
  end

  def name
    about[..50]
    case false
    when product_name.blank?; product_name[..50]
    when about.blank?; about[..50]
    when comment.blank?; comment[..50]
    end
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_about(flt["about"])
  rescue
    filter.destroy if filter
    all
  end

  def has_mugshot?
    false
  end

  def self.form(resource:, editable: true)
    TimeMaterials::Form.new resource: resource, editable: editable
  end

  def units
    [
      [ "hours", I18n.t("time_material.units.hours") ],
      [ "parts", I18n.t("time_material.units.parts") ],
      [ "km", I18n.t("time_material.units.km") ],
      [ "day", I18n.t("time_material.units.day") ],
      [ "week", I18n.t("time_material.units.week") ],
      [ "month", I18n.t("time_material.units.month") ],
      [ "kilogram", I18n.t("time_material.units.kilogram") ],
      [ "cubicMetre", I18n.t("time_material.units.cubicMetre") ],
      [ "set", I18n.t("time_material.units.set") ],
      [ "litre", I18n.t("time_material.units.litre") ],
      [ "box", I18n.t("time_material.units.box") ],
      [ "case", I18n.t("time_material.units.case") ],
      [ "carton", I18n.t("time_material.units.carton") ],
      [ "metre", I18n.t("time_material.units.metre") ],
      [ "package", I18n.t("time_material.units.package") ],
      [ "shipment", I18n.t("time_material.units.shipment") ],
      [ "squareMetre", I18n.t("time_material.units.squareMetre") ],
      [ "session", I18n.t("time_material.units.session") ],
      [ "tonne", I18n.t("time_material.units.tonne") ]
    ]
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
      days, hours = t.divmod 86400
      hours, minutes = hours.divmod 3600
      minutes, seconds = minutes.divmod 60
      [ days, hours, minutes, seconds ]
  end

  def calc_time_to_decimal(t)
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
      "%s.%i" % [ t[0], t[1] ]
    end
  end

  #
  # make sure this record is good for pushing to the ERP
  #
  def values_ready_for_push?
    return false if customer.nil? # check if customer exists/association set correctly
    entry = InvoiceItemValidator.new(self)
    return true if entry.valid?
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
end
