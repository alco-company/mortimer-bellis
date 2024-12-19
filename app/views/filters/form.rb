class Tenants::Form < ApplicationForm
  def view_template(&)
    row field(:view).input().focus
    row field(:filter).input()
  end
end
