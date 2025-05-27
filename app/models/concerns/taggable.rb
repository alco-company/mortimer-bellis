module Taggable
  extend ActiveSupport::Concern

  included do
    attr_accessor :tag_list
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings

    def tag_names
      tags.map(&:name).join(", ")
    end

    def tag_list
      @tag_list ||= tags.map(&:name).join(", ")
    end

    def tag_list=(value)
      return unless value.is_a?(String)
      self.taggings.each { |tg| tg.delete }
      return if value.blank?
      value.split(",").map(&:strip).each do |tagID|
        self.taggings << Tagging.new(taggable: self, tag: Tag.find(tagID), tagger: Current.get_user) unless taggings.where(tag_id: tagID).exists?
      end
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
