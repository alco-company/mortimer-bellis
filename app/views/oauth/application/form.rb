class Oauth::Application::Form < ApplicationForm
  def view_template(&)
    div() do
      row field(:name).input(class: "mort-form-text").focus
      row field(:redirect_uri).textarea(class: "mort-form-text")
      row field(:scopes).input(class: "mort-form-text")
      row field(:confidential).boolean(class: "mort-form-bool"), "mort-field flex justify-end flex-row-reverse items-center"
      view_only field(:uid).date(class: "mort-form-text font-mono")
      view_only field(:secret).date(class: "mort-form-text font-mono")
    end
  end
end
