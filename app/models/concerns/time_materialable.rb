module TimeMaterialable
  extend ActiveSupport::Concern

  included do
    has_many :time_materials, dependent: :destroy
  end

  class_methods do
  end
end
