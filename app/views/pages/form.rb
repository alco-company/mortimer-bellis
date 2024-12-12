class Pages::Form < ApplicationForm
  def view_template(&)
    model.class.attribute_types.each do |key, type|
      case type.class.to_s
      when "ActiveModel::Type::String"; row field(key.to_sym).input(class: "mort-form-text")
      when "ActiveRecord::Type::Text"; row field(key.to_sym).textarea(class: "mort-form-text")
      else
      end
    end
    # row field(:slug).input(class: "mort-form-text")
    # row field(:title).input(class: "mort-form-text").focus
    # row field(:content).textarea(class: "mort-form-text")
  end
end
