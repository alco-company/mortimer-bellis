class Pages::Form < ApplicationForm
  def view_template(&)
    row field(:slug).input(class: "mort-form-text")
    row field(:title).input(class: "mort-form-text").focus
    row field(:content).textarea(class: "mort-form-text")
  end
end
