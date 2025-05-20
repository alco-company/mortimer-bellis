class TagsController < MortimerController
  def tags
    # add a tag
    tag = add_tag
    # if params[:add_tag].present?
    #   tag = Tag.find_or_create_by(name: params[:add_tag], tenant_id: Current.get_tenant.id, created_by: Current.get_user)
    # end

    # find tags
    unless params[:search].blank?
      tags = Tag.by_tenant.where("name LIKE ?", "%#{params[:search]}%").order("name ASC").limit(10)
      search = params[:search]
    else
      tags = []
      search = ""
    end

    # select tags
    if params[:value].blank?
      value = tag.present? ? [ tag ] : []
    else
      ids = params[:value].to_s.split(",").map(&:strip)
      ids.push tag.id if tag.present?
      value = Tag.by_tenant.where(id: ids) rescue []
    end

    # show the result
    respond_to do |format|
      format.turbo_stream { render partial: "tags/tags", locals: { tags:, search:, value: } }
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
        tag_info = params[:add_tag].split(":")
        context = tag_info.size > 1 ? tag_info[0] : ""
        category = tag_info.size > 2 ? tag_info[1] : ""
        name = tag_info.last
        Tag.find_or_create_by(name: name,
          tenant_id: Current.get_tenant.id,
          context: context,
          category: category,
          created_by: Current.get_user)
      else
        nil
      end
    end
end
