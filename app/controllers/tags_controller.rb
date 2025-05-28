class TagsController < MortimerController
  def tags
    @resource_class = params[:context].to_s.classify.constantize
    @resource = params[:id].present? ? @resource_class.find(params[:id]) : @resource_class.new

    field = params[:field].to_s
    # add a tag
    tag = add_tag
    # if params[:add_tag].present?
    #   tag = Tag.find_or_create_by(name: params[:add_tag], tenant_id: Current.get_tenant.id, created_by: Current.get_user)
    # end

    # find tags
    unless params[:search].blank?
      case true
      # context:category:name
      when params[:search].count(":") == 2
        context, category, name = params[:search].split(":")
        tags = Tag.by_tenant
          .where("context like ?", "%#{context}%")
          .where("category like ?", "%#{category}%")
          .where("name like ?", "%#{name}%")
          .order("context, category, name ASC").limit(10)

      # category:name
      when params[:search].count(":") == 1
        category, name = params[:search].split(":")
        tags = Tag.by_tenant
          .where("category like ?", "%#{category}%")
          .where("name LIKE ?", "%#{name}%")
          .order("category, name ASC").limit(10)

      else
        tags = Tag.by_tenant
          .where("name LIKE ?", "%#{params[:search]}%")
          .order("name ASC").limit(10)
      end
      search = params[:search]
    else
      tags = []
      search = ""
    end

    # select tags
    if params[:value].blank?
      value = tag.nil? ? [] : [ tag ]
    else
      ids = params[:value].to_s.split(",").map(&:strip)
      ids.push tag.id unless tag.nil?
      value = Tag.by_tenant.where(id: ids) rescue []
    end

    # show the result
    respond_to do |format|
      format.turbo_stream { render partial: "tags/tags", locals: { resource: @resource, field:, tags:, search:, value: } }
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(tag: [ :tenant_id, :name, :created_by, :context, :category, :count ])
    end

    # add tag
    # @return [Tag] the tag object
    # @return [nil] if no tag is added
    #
    # @example
    #   add_tag
    #
    # params[:add_tag] holds the name of the tag to be added
    # and possibly the category and context in a formatted string
    # like "context:category:name"
    def add_tag
      if params[:add_tag].present?
        name, category, context = set_tag_from params[:add_tag]
        Tag.find_or_create_by(name: name,
          tenant_id: Current.get_tenant.id,
          context: context,
          category: category,
          created_by: Current.get_user)
      else
        nil
      end
    end

    def set_tag_from(tag)
      return [ nil, nil, nil ] if tag.blank?
      tag = ":%s" % tag if tag.count(":") < 1
      tag = "%s:%s" % [ get_context, tag ] if tag.count(":") < 2
      tag.split(":").reverse
    end

    def get_context
      params[:context].present? ? params[:context] : ""
    end
end
