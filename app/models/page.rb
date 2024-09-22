class Page < ApplicationRecord
  scope :by_tenant, -> { all }

  def name
    title
  end

  def self.form(resource, editable = true)
    Pages::Form.new resource, editable: editable
  end
end
