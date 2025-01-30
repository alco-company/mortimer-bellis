class Filter < ApplicationRecord
  include Tenantable

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

  belongs_to :user, optional: true
  scope :by_user, ->(user = Current.user) { where(user: user) if user.present? }
  scope :by_view, ->(view) { where(view: view) if view.present? }

  def do_filter(model)
    conditions = []
    model.column_names.map do |column|
      if filter_argument?(model, column)
        conditions << filter_sql(model, column)
      end
    end
    conditions.reduce(:and) || model.all
  end

  def self.form(resource:, url:, filter_form:, params:, editable: true)
    ::Filters::Form.new resource: resource, url: url, filter_form: filter_form, editable: editable, params: params
  end

  def filter_argument?(model, column)
    model = model.to_s.underscore
    filter[model][column].present? && !filter[model][column].split("|")[1].blank?
  end

  def filter_sql(model, column, joined = false)
    model_name = model.to_s.underscore

    selected, value = filter[model_name][column].split("|")
    if joined
      # " #{model.pluralize}.#{column} %s %s " % [ selected, value ]
    else
      model.where_op(selected.to_sym, column.to_sym => value.downcase)
    end
  end
end
