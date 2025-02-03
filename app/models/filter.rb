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
    # {"date"=>{"attribute"=>"paused_at", "fixed_range"=>"this_week", "custom_from"=>"", "custom_to"=>""},
    conditions = filter_for_date(model, conditions)
    # "time_material"=> {"about"=>"|", "customer_name"=>"|", "project_name"=>"|", "product_name"=>"|", "quantity"=>"|", "rate"=>"|", "discount"=>"|", "state"=>"|", "is_invoice"=>"|", "is_free"=>"|", "is_offer"=>"|", "is_separate"=>"|", "comment"=>"|", "unit_price"=>"|", "unit"=>"|", "time_spent"=>"|", "over_time"=>"|"},
    model.column_names.map do |column|
      if filter_argument?(model, column)
        conditions << filter_sql(model, column)
      end
    end
    conditions = filter_for_scope model, conditions
    conditions = filter_for_associations model, conditions
    conditions.reduce(:and) || model.all
  end

  def self.form(resource:, url:, filter_form:, params:, editable: true)
    ::Filters::Form.new resource: resource, url: url, filter_form: filter_form, editable: editable, params: params
  end

  def filter_for_date(model, conditions)
    return conditions if filter["date"]["fixed_range"].blank? && filter["date"]["custom_from"].blank? && filter["date"]["custom_to"].blank?

    unless filter["date"]["fixed_range"].blank?
      today = DateTime.current.beginning_of_day
      case filter["date"]["fixed_range"]
      when "today"
        conditions << model.where_op(:eq, filter["date"]["attribute"] => today)
      when "yesterday"
        conditions << model.where_op(:gt, filter["date"]["attribute"] => today - 1.day)
      when "this_week"
        conditions << model.where_op(:gteq, filter["date"]["attribute"] => today.at_beginning_of_week)
      when "last_week"
        conditions << model.where_op(:between, filter["date"]["attribute"] => today.at_beginning_of_week - 7.days..today.at_beginning_of_week)
      when "this_month"
        conditions << model.where_op(:gteq, filter["date"]["attribute"] => today.beginning_of_month)
      when "last_month"
        conditions << model.where_op(:between, filter["date"]["attribute"] => today.beginning_of_month - 1.month..today.beginning_of_month)
      when "this_year"
        conditions << model.where_op(:gteq, filter["date"]["attribute"] => today.beginning_of_year)
      when "last_year"
        conditions << model.where_op(:between, filter["date"]["attribute"] => today.beginning_of_year - 1.year..today.beginning_of_year)
      end
    end
    unless filter["date"]["custom_from"].blank?
      cf = DateTime.parse(filter["date"]["custom_from"]).beginning_of_day rescue nil
      conditions << model.where_op(:gteq, filter["date"]["attribute"] => cf)
    end
    unless filter["date"]["custom_to"].blank?
      ct = DateTime.parse(filter["date"]["custom_to"]).end_of_day rescue nil
      conditions << model.where_op(:lteq, filter["date"]["attribute"] => ct)
    end
    conditions
  end

  #  "scope"=>{"user"=>"my_team", "named_users_teams"=>""},
  #
  def filter_for_scope(model, conditions)
    unless filter["scope"]["user"].blank?
      conditions << model.send(:user_scope, filter["scope"]["user"])
    end
    unless filter["scope"]["named_users_teams"].blank?
      conditions << model.send(:named_scope, filter["scope"]["named_users_teams"])
    end
    unless filter["customer_id"].blank?
      conditions << model.where(customer_id: filter["customer_id"])
    end
    unless filter["project_id"].blank?
      conditions << model.where(project_id: filter["project_id"])
    end
    unless filter["product_id"].blank?
      conditions << model.where(product_id: filter["product_id"])
    end
    conditions
  end

  def filter_for_associations(model, conditions)
    # TODO implement filter for associations
    conditions
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
