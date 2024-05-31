module ModalHelper
  def delete_modal_title
    @resource.present? ?
      I18n.t("#{@resource_class.to_s.underscore}.modal.delete.title") :
      I18n.t("#{@resource_class.to_s.underscore}.modal.delete_all.title")
  end
  def delete_modal_instruction
    @resource.present? ?
      I18n.t("#{@resource_class.to_s.underscore}.modal.delete.instruction", name: @resource.name) :
      I18n.t("#{@resource_class.to_s.underscore}.modal.delete_all.instruction")
  end
end
