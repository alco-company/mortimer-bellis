# frozen_string_literal: true

class Editors::Html::UI < ApplicationComponent
  def view_template
    div(class: "flex h-screen") do
      # Editor pane
      div(class: "w-1/2 p-4 border-r overflow-y-auto") do
        h2(class: "text-xl font-bold mb-4") { "Editor" }
        render Editors::Html::Form.new
      end

      # Preview pane
      div(id: "preview-pane", class: "w-1/2 p-4 overflow-y-auto bg-gray-50") do
        h2(class: "text-xl font-bold mb-4") { "Preview" }
        render Editors::Html::Preview.new
      end
    end
  end
end
