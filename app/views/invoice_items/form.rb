class InvoiceItems::Form < ApplicationForm
  def view_template(&)
    row field(:invoice_id).select(Invoice.by_tenant.order(invoice_number: :asc).select(:id, :invoice_number), prompt: I18n.t(".select_invoice"), class: "mort-form-select")
    row field(:project_id).select(Project.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_project"), class: "mort-form-select")
    row field(:product_id).select(Product.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_product"), class: "mort-form-select")
    row field(:product_guid).input()
    row field(:description).input()
    row field(:comments).textarea(class: "mort-form-text")
    row field(:quantity).input()
    row field(:account_number).input()
    row field(:unit).input()
    row field(:discount).input()
    row field(:line_type).input()
    row field(:base_amount_value).input()
    row field(:base_amount_value_incl_vat).input()
    row field(:total_amount).input()
    row field(:total_amount_incl_vat).input()
  end
end
