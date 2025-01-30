class Filter < ApplicationRecord
  SELECTORS = [
    [ I18n.t("one_of"), "in" ],
    [ I18n.t("not_one_of"), "not_in" ],
    [ I18n.t("between"), "between" ],
    [ I18n.t("not_between"), "not_between" ],
    [ I18n.t("equal_to"), "eq" ],
    [ I18n.t("not_equal_to"), "not_eq" ],
    [ I18n.t("less_than"), "lt" ],
    [ I18n.t("less_than_equal"), "lteq" ],
    [ I18n.t("greater_than"), "gt" ],
    [ I18n.t("greater_than_equal"), "gteq" ],
    [ I18n.t("matches"), "matches" ],
    [ I18n.t("not_matching"), "does_not_match" ]
  ]
  include Tenantable

  belongs_to :user, optional: true
  scope :by_user, ->(user = Current.user) { where(user: user) if user.present? }
  scope :by_view, ->(view) { where(view: view) if view.present? }

  def do_filter(model)
    resources = model
    model_name = model.to_s.underscore
    model.column_names.map do |column|
      if filter_argument?(model_name, column)
        resources = filter_sql resources, model_name, column
      end
    end
    resources
  end

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

  def filter_argument?(model, column)
    filter[model][column].present? && !filter[model][column].split("|")[1].blank?
  end

  def filter_sql(resources, model, column, joined = false)
    selected, value = filter[model][column].split("|")
    if joined
      # " #{model.pluralize}.#{column} %s %s " % [ selected, value ]
    else
      resources.where_op(selected.to_sym, column.to_sym => value)
    end
  end
  #
  # associations on the model
  # will pull from the json_filter
  # and return the association.id & association.name
  #

  # # customer
  # def customer_id
  #   "829"
  # end

  # def customer_name
  #   "Nordthy A/S"
  # end

  # # punch_clock
  # def punch_clock_id
  # end

  # def punch_clock_name
  # end

  # # product
  # def product_id
  # end

  # def product_name
  # end
  # # location
  # def location_id
  # end

  # def location_name
  # end
  # # invoice
  # def invoice_id
  # end

  # def invoice_name
  # end
  # # invoice_item
  # def invoice_item_id
  # end

  # def invoice_item_name
  # end
  # # project
  # def project_id
  # end

  # def project_name
  # end
end
