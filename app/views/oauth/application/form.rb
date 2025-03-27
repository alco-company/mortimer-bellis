class Oauth::Application::Form < ApplicationForm
  def view_template(&)
    div() do
      row field(:name).input().focus
      row field(:redirect_uri).textarea(class: "mort-form-text")
      row field(:scopes).input()
      row field(:confidential).boolean(class: "mort-form-bool"), "mort-field flex justify-end flex-row-reverse items-center"
      view_only field(:uid).date(class: "mort-form-date font-mono")
      view_only field(:secret).date(class: "mort-form-date font-mono")
    end
  end
end
