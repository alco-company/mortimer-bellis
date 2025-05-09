module ModalHelper
  def delete_modal_title
    return I18n.t("modal.destroy.#{@attachment}.title", name: resource.name) if @attachment.present?
    resource.id.present? ?
      I18n.t("#{resource_class.to_s.underscore}.modal.delete.title") :
      I18n.t("#{resource_class.to_s.underscore}.modal.delete_all.title")
  end
  def delete_modal_instruction
    return I18n.t("modal.destroy.#{@attachment}.instruction", name: resource.name) if @attachment.present?
    resource.id.present? ?
      I18n.t("#{resource_class.to_s.underscore}.modal.delete.instruction", name: resource.name) :
      case true
      when filtered_or_batched?; I18n.t("#{resource_class.to_s.underscore}.modal.delete_all.instruction_selected", count: resources.count)
      else ; I18n.t("#{resource_class.to_s.underscore}.modal.delete_all.instruction", count: resources.count)
      end
  end

  def export_modal_title
    "Eksportér"
  end

  def export_modal_instruction
    "instruktion"
  end

  def delete_account_modal_title
    I18n.t("modal.destroy.account.title")
  end

  def delete_account_modal_instruction
    I18n.t("modal.destroy.account.instruction")
  end

  def set_all_true
    !resource.id.present? # and !filtered_or_batched?
  end

  def filtered_or_batched?
    (@filter&.filter != {}) || @batch&.batch_set? || @search.present?
  end
end
