class Page < ApplicationRecord
  scope :by_tenant, -> { all }

  def name
    title
  end

  def tenant
    false
  end

  def self.set_order(resources, field = :title, direction = :asc)
    resources.ordered(field, direction)
  end

  def self.form(resource:, editable: true)
    Pages::Form.new resource: resource, editable: editable
  end
end
