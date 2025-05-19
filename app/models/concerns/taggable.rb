module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings

    def tag_names
      tags.map(&:name).join(", ")
    end
  end

  class_methods do
    def taggable_types
      %w[TimeMaterial Customer Product Project Team Location]
    end

    def taggable_class_names
      taggable_types.map(&:constantize)
    end
  end
end
