class Batch < ApplicationRecord
  belongs_to :tenant
  belongs_to :user

  def entities
    @entities ||= find_entities
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
