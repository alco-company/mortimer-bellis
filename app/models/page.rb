class Page < ApplicationRecord
  scope :by_tenant, -> { all }
  # mortimer_scoped - override on tables with other tenant scoping association
  scope :mortimer_scoped, ->(ids) { unscoped.where("0=#{ids}") } # effectively returns no records

  def self.scoped_for_tenant(ids = 1)
    mortimer_scoped(ids)
  end

  def name
    title
  end

  def tenant
    false
  end

  def slug=(value)
    @slug = (value || title).split.map { |w| w.capitalize }.join.underscore
  end

  def self.set_order(resources, field = :title, direction = :asc)
    resources.ordered(field, direction)
  end

  # if the view is a standard CRU(d) view, the form can be generated
  # by trusting the inherited form method off of the ApplicationRecord
  # class. If the form is more complex, a custom form class can be
  # created in the app/views/{models} directory - fx app/views/pages/form.rb
  # defining Pages::Form < ApplicationForm - either defining every field
  # or calling form_fields fields: [ :slug, :title, :content ]
  # or uncomment the following method and adjust the fields
  #
  # def self.form(resource:, editable: true)
  #   Pages::Form.new resource: resource, editable: editable, fields: [ :slug, :title, :content ]
  # end
end
