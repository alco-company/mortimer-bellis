module ModalHelper
  def delete_modal_title
    return I18n.t("modal.destroy.#{@attachment}.title", name: @resource.name) if @attachment.present?
    @resource.id.present? ?
      I18n.t("#{@resource_class.to_s.underscore}.modal.delete.title") :
      I18n.t("#{@resource_class.to_s.underscore}.modal.delete_all.title")
  end
  def delete_modal_instruction
    return I18n.t("modal.destroy.#{@attachment}.instruction", name: @resource.name) if @attachment.present?
    @resource.id.present? ?
      I18n.t("#{@resource_class.to_s.underscore}.modal.delete.instruction", name: @resource.name) :
      I18n.t("#{@resource_class.to_s.underscore}.modal.delete_all.instruction")
  end
end
