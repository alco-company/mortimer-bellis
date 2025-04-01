class Batch < ApplicationRecord
  belongs_to :tenant
  belongs_to :user

  def batch_set?
    persisted? and !ids.blank?
  end

  def entities(collection)
    # @entities ||= find_entities
    find_entities(collection)
  end

  def ids_range
    is= ids.split(",").collect { |i| i.to_i }.sort
    is.first..is.last
  rescue
    0..0
  end

  def persist(params)
    params[:ids] = params[:ids].join(",")
    update(params)
  end

  def self.user_scope(scope)
    case scope
    when "all"; nil # all.by_tenant()
    when "mine"; TimeMaterial.arel_table[:user_id].eq(Current.user.id)
    when "my_team"; TimeMaterial.arel_table[:user_id].in(Current.user.team.users.pluck(:id))
    end
  end

  def self.named_scope(scope)
    TimeMaterial.arel_table[:user_id].
    in(
      User.arel_table.project(:id).where(
        User[:name].matches("%#{scope}%").
        or(User[:team_id].in(Team.arel_table.project(:id).where(Team[:name].matches("%#{scope}%"))))
      )
    )
  end

  private
    def find_entities(collection)
      entity_class = entity.constantize
      return collection.all if all
      return entity_class.none if ids.blank?
      tids = ids.blank? ? [] : ids.split(",")
      collection.where(id: tids)
    end
end
