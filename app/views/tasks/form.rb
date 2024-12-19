class Tasks::Form < ApplicationForm
  def view_template(&)
    row field(:title).input().focus
    row field(:link).input()
    row field(:priority).number()
    row field(:description).textarea(class: "mort-form-text"), "mort-field my-0"
    row field(:validation).textarea(class: "mort-form-text"), "mort-field my-5"
  end
end
