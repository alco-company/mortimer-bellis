class Products::Form < ApplicationForm
  def view_template(&)
    row field(:name).input().focus
    row field(:product_number).input()
    row field(:quantity).input()
    row field(:unit).select(@resource.units, class: "mort-form-select text-sm"), "mort-field my-1"
    row field(:base_amount_value).money(value: number_to_currency(@resource.base_amount_value))
    row field(:account_number).input()
    row field(:external_reference).input()
    view_only field(:transmit_log).input()
  end
end
