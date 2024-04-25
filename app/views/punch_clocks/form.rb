class PunchClocks::Form < ApplicationForm
  def view_template(&)
    view_only field(:access_token).input(class: "mort-form-text")
    row field(:name).input(class: "mort-form-text").focus
    row field(:location_id).select(Location.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_locatioin"), class: "mort-form-text")
    row field(:ip_addr).input(class: "mort-form-text").focus
    row field(:locale).input(class: "mort-form-text").focus
    row field(:time_zone).input(class: "mort-form-text").focus
  end
end
