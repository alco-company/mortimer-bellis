class TimeMaterial < ApplicationRecord
  include Tenantable
  include TimeMaterialStateable

  belongs_to :customer, optional: true
  belongs_to :project, optional: true
  belongs_to :product, optional: true
  belongs_to :user

  scope :by_about, ->(about) { where("about LIKE ?", "%#{about}%") if about.present? }
  scope :by_exact_user, ->(user) { where("user_id= ?", "%#{user.id}%") if user.present? }

  # validates :about, presence: true

  validates :about, presence: true, if: [ Proc.new { |c| c.comment.blank? && c.product_name.blank? } ]

  def list_item(links: [], context:)
    TimeMaterialDetailItem.new(item: self, links: links, id: context.dom_id(self))
  end

  def name
    about[..50]
    case false
    when about.blank?; about[..50]
    when product_name.blank?; product_name[..50]
    when comment.blank?; comment[..50]
    end
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_about(flt["about"])
  rescue
    filter.destroy if filter
    all
  end

  def has_mugshot?
    false
  end

  def self.form(resource:, editable: true)
    TimeMaterials::Form.new resource: resource, editable: editable
  end
end
