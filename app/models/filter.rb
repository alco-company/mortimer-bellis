class Filter < ApplicationRecord
  include Tenantable

  belongs_to :user, optional: true
  scope :by_view, ->(view) { where("view LIKE ?", "%#{view}%") if view.present? }

  def self.filtered(filter)
    flt = filter.filter

    all
      # .by_tenant()
      .by_view(flt["view"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource:, url:, filter_form:, params:, editable: true)
    ::Filters::Form.new resource: resource, url: url, filter_form: filter_form, editable: editable, params: params
  end

  #
  # associations on the model
  # will pull from the json_filter
  # and return the association.id & association.name
  #

  # customer
  def customer_id
    "829"
  end

  def customer_name
    "Nordthy A/S"
  end

  # punch_clock
  def punch_clock_id
  end

  def punch_clock_name
  end

  # product
  def product_id
  end

  def product_name
  end
  # location
  def location_id
  end

  def location_name
  end
  # invoice
  def invoice_id
  end

  def invoice_name
  end
  # invoice_item
  def invoice_item_id
  end

  def invoice_item_name
  end
  # project
  def project_id
  end

  def project_name
  end
end
