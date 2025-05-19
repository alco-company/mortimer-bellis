class TagsController < MortimerController
  def tags
    if params[:add_tag].present?
      tag = Tag.find_or_create_by(name: params[:add_tag], tenant_id: Current.get_tenant.id, created_by: Current.get_user)
    end
    unless params[:search].blank?
      tags = Tag.by_tenant.where("name LIKE ?", "%#{params[:search]}%").order("name ASC").limit(10)
      search = params[:search]
    else
      tags = []
      search = ""
    end
    if params[:value].blank?
      value = tag.present? ? [ tag ] : []
    else
      ids = params[:value].to_s.split(",").map(&:strip)
      ids.push tag.id if tag.present?
      value = Tag.by_tenant.where(id: ids) rescue []
    end

    respond_to do |format|
      format.turbo_stream { render partial: "tags/tags", locals: { tags:, search:, value: } }
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def tag_params
      params.expect(tag: [ :tenant_id, :name, :count ])
    end
end
