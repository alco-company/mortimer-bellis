class Dashboards::Form < ApplicationForm
  def view_template(&)
    row field(:feed).input().focus
    row field(:last_feed_at).datetime(class: "mort-form-text")
  end
end
