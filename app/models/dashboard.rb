class Dashboard < ApplicationRecord
  include Tenantable

  def name
    feed
  end

  def self.form(resource, editable = true)
    Dashboards::Form.new resource, editable: editable
  end
end
