class Products::Form < ApplicationForm
  def view_template(&)
    row field(:name).input().focus
    row field(:product_number).input()
    row field(:quantity).input()
    row field(:unit).input()
    row field(:base_amount_value).input()
    row field(:account_number).input()
    row field(:external_reference).input()
  end
end
