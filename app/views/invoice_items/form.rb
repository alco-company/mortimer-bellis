class InvoiceItems::Form < ApplicationForm
  def view_template(&)
    row field(:invoice_id).select(Invoice.by_tenant.order(invoice_number: :asc).select(:id, :invoice_number), prompt: I18n.t(".select_invoice"), class: "mort-form-text")
    row field(:project_id).select(Project.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_project"), class: "mort-form-text")
    row field(:product_id).select(Product.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_product"), class: "mort-form-text")
    row field(:product_guid).input(class: "mort-form-text")
    row field(:description).input(class: "mort-form-text")
    row field(:comments).textarea(class: "mort-form-text")
    row field(:quantity).input(class: "mort-form-text")
    row field(:account_number).input(class: "mort-form-text")
    row field(:unit).input(class: "mort-form-text")
    row field(:discount).input(class: "mort-form-text")
    row field(:line_type).input(class: "mort-form-text")
    row field(:base_amount_value).input(class: "mort-form-text")
    row field(:base_amount_value_incl_vat).input(class: "mort-form-text")
    row field(:total_amount).input(class: "mort-form-text")
    row field(:total_amount_incl_vat).input(class: "mort-form-text")
  end
end
