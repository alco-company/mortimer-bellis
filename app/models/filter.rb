class Filter < ApplicationRecord
  include Tenantable

  attr_accessor :conditions, :tbl

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
  scope :by_fulltext, ->(query) { where("view LIKE :query OR name LIKE :query", query: "%#{query}%") if query.present? }

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      "user_id"
    ]
    f = f - [
      "created_at",
      "updated_at"
      ] if model == self
    f
  end

  def do_filter(model, relation)
    @conditions = []
    @tbl = model.arel_table

    # {"date"=>{"attribute"=>"paused_at", "fixed_range"=>"this_week", "custom_from"=>"", "custom_to"=>""},
    filter_for_date

    # "time_material"=> {"about"=>"|", "customer_name"=>"|", "project_name"=>"|", "product_name"=>"|", "quantity"=>"|", "rate"=>"|", "discount"=>"|", "state"=>"|", "is_invoice"=>"|", "is_free"=>"|", "is_offer"=>"|", "is_separate"=>"|", "comment"=>"|", "unit_price"=>"|", "unit"=>"|", "time_spent"=>"|", "over_time"=>"|"},
    model.column_names.map do |column|
      if filter_argument?(model, column)
        filter_sql(model, column)
      end
    end
    filter_for_scope model
    filter_for_associations model
    relation.where(conditions.reduce(:and))
  rescue => e
    # debug-ger
    UserMailer.error_report(e.message, "Filter#do_filter failed ").deliver_later
    relation
  end

  def self.form(resource:, url:, filter_form:, params:, editable: true)
    ::Filters::Form.new resource: resource, url: url, filter_form: filter_form, editable: editable, params: params
  end

  def filter_for_date
    return if filter["date"]["fixed_range"].blank? && filter["date"]["custom_from"].blank? && filter["date"]["custom_to"].blank?

    date_attr =filter["date"]["attribute"].to_sym

    unless filter["date"]["fixed_range"].blank?
      today = DateTime.current.beginning_of_day
      case filter["date"]["fixed_range"]
      when "today"     ; conditions << tbl[date_attr].eq(today)
      when "yesterday" ; conditions << tbl[date_attr].eq(today - 1.day)
      when "this_week" ; conditions << tbl[date_attr].gteq(today.at_beginning_of_week)
      when "last_week" ; conditions << tbl[date_attr].between(today.at_beginning_of_week - 7.days..today.at_beginning_of_week)
      when "this_month"; conditions << tbl[date_attr].gteq(today.beginning_of_month)
      when "last_month"; conditions << tbl[date_attr].between(today.beginning_of_month - 1.month..today.beginning_of_month)
      when "this_year" ; conditions << tbl[date_attr].gteq(today.beginning_of_year)
      when "last_year" ; conditions << tbl[date_attr].between(today.beginning_of_year - 1.year..today.beginning_of_year)
      end
    end
    unless filter["date"]["custom_from"].blank?
      cf = DateTime.parse(filter["date"]["custom_from"]).beginning_of_day rescue nil
      conditions << tbl[date_attr].gteq(cf)
    end
    unless filter["date"]["custom_to"].blank?
      ct = DateTime.parse(filter["date"]["custom_to"]).end_of_day rescue nil
      conditions << tbl[date_attr].lteq(ct)
    end
  end

  #  "scope"=>{"user"=>"my_team", "named_users_teams"=>""},
  #
  def filter_for_scope(model)
    unless filter["scope"]["user"].blank?
      arg = model.send(:user_scope, filter["scope"]["user"])
      conditions << arg unless arg.nil?
    end
    unless filter["scope"]["named_users_teams"].blank?
      arg = model.send(:named_scope, filter["scope"]["named_users_teams"])
      conditions << arg unless arg.nil?
    end
    unless filter["customer_id"].blank?
      conditions << tbl[:customer_id].eq(filter["customer_id"])
    end
    unless filter["project_id"].blank?
      conditions << tbl[:project_id].eq(filter["project_id"])
    end
    unless filter["product_id"].blank?
      conditions << tbl[:product_id].eq(filter["product_id"])
    end
    unless filter["location_id"].blank?
      conditions << tbl[:location_id].eq(filter["location_id"])
    end
  end

  def filter_for_associations(model)
    # TODO implement filter for associations
    # conditions
  end

  def filter_argument?(model, column)
    model = model.to_s.underscore
    filter[model][column].present? && !filter[model][column].split("|")[1].blank?
  end

  def filter_sql(model, column, joined = false)
    model_name = model.to_s.underscore

    selected, value = filter[model_name][column].split("|")
    value = case selected
    when "matches", "does_not_match", "in"; "%%%s%%" % value
    else; value
    end
    if joined
      # " #{model.pluralize}.#{column} %s %s " % [ selected, value ]
    else
      conditions << tbl[column.to_sym].send(selected.to_sym, value.downcase)
    end
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

  # def self.user_scope(scope)
  #   case scope
  #   when "all"; nil # all.by_tenant()
  #   when "mine"; where(user_id: Current.user.id)
  #   when "my_team"; where(user_id: Current.user.team.users.pluck(:id))
  #   end
  # end

  # def self.named_scope(scope)
  #   users = User.where name: "%#{scope}%"
  #   team_users = User.where team_id: Team.where_op(:matches, name: "%#{scope}%").pluck(:id)
  #   users = users + team_users if team_users.any?
  #   where(user_id: users.pluck(:id))
  # end
end
