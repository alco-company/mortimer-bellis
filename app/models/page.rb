class Page < ApplicationRecord
  scope :by_account, -> { all }

  def name
    title
  end

  def self.form(resource, editable = true)
    Pages::Form.new resource, editable: editable
  end
end
