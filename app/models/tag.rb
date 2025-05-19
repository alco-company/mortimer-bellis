class Tag < ApplicationRecord
  include Tenantable
  has_many :taggings, dependent: :destroy
  has_many :taggables, through: :taggings
  belongs_to :created_by, class_name: "User", foreign_key: "user_id"
  validates :name, presence: true
  # validates :name, uniqueness: { scope: :tenant_id, message: I18n.t("tags.errors.messages.name_exist") }
end
