class Tags::Form < ApplicationForm
  def view_template(&)
    row field(:name).input().focus
    row field(:category).input()
    row field(:context).input()
    view_only field(:created_by).input(value: model.created_by)
    view_only field(:count).number()
  end
end
