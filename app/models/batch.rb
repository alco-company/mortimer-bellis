class Batch < ApplicationRecord
  belongs_to :tenant
  belongs_to :user

  def entities
    @entities ||= find_entities
  end

  def ids_range
    is= ids.split(",").collect { |i| i.to_i }.sort
    is.first..is.last
  rescue
    0..0
  end

  private
    def find_entities
      entity_class = entity.constantize
      return entity_class.all if all
      return entity_class.none if ids.empty?
      tids = ids.blank? ? [] : ids.split(",")
      entity_class.where(id: tids)
    end
end
