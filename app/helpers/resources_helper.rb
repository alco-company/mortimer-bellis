module ResourcesHelper
  include Resourceable

  def is_checked?(item)
    @filter.ids.include? item.id.to_s
  rescue
    false
  end
end
