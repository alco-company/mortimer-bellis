class Tasks::Form < ApplicationForm
  def view_template(&)
    row field(:title).input().focus
    row field(:link).input()
    row field(:description).textarea(class: "mort-form-text"), "mort-field my-0"
    row field(:validation).textarea(class: "mort-form-text"), "mort-field my-0"
  end
end
