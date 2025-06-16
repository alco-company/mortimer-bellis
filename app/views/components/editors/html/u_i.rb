# frozen_string_literal: true

class Editors::Html::UI < ApplicationComponent
  def initialize(document: nil)
    @document = document
    super()
  end

  # This method will render the HTML structure editor UI.
  def view_template
    div(class: "absolute inset-0") do
      div(id: "editor_fixed_container", class: "fixed inset-y-20 left-0 lg:left-64 right-0 mt-2 flex flex-col h-[calc(100vh-0.5rem)] overflow-hidden", data: { controller: "tabs editor" }) do
        span(class: "ml-4 font-semibold") { @document.title }
        show_tabs
        show_tab_content
      end
    end
  end

  def show_tabs
    # Tabs
    selected_tab = "border-b-2 border-sky-500 text-sky-600"
    div(class: "flex border-b border-gray-200 text-sm font-medium") do
      [  "HTML", "Preview" ].each_with_index do |name, i| # hidden "Blocks" tab for now
        button(
          type: "button",
          value: i,
          class: "px-4 py-2 #{} #{selected_tab if i == 0} hover:bg-gray-100 focus:outline-none ",
          data: { action: "click->tabs#change", tabs_target: "tab" }
        ) { name }
      end
    end
  end

  def show_tab_content
    div(class: "flex-1 overflow-auto p-4") do
      # show_blocks_tab_content
      show_html_tab_content
      show_preview_tab_content
    end
  end

  # Blocks view
  def show_blocks_tab_content
    render Editors::Html::EditorBlock.new(document: @document)
  end

  # HTML view
  def show_html_tab_content
    div(class: "hidden", data: { tabs_target: "tabPanel" }) do
      render Editors::Html::Form.new document: @document
    end
  end

  # Preview view
  def show_preview_tab_content
    div(class: "hidden", data: { tabs_target: "tabPanel" }) do
      div(data: { controller: "preview" }, class: "flex-1 flex flex-col overflow-auto p-4 bg-gray-50") do
        # Device toggle
        div(class: "mb-4 space-x-2") do
          button(
            class: "px-3 py-1  cursor-pointer rounded border bg-white hover:bg-gray-100",
            data: { action: "click->preview#setSize", preview_size_param: "375" }
          ) { "Mobile" }
          button(
            class: "px-3 py-1 cursor-pointer rounded border bg-white hover:bg-gray-100",
            data: { action: "click->preview#setSize", preview_size_param: "768" }
          ) { "Tablet" }
          button(
            class: "px-3 py-1 cursor-pointer rounded border bg-white hover:bg-gray-100",
            data: { action: "click->preview#setSize", preview_size_param: "full" }
          ) { "Desktop" }
          button(
            class: "px-3 py-1 rounded border bg-gray-100 hover:bg-gray-100",
            data: { action: "click->preview#setSize", preview_size_param: "pdf" }
          ) { "PDF" }
        end

        # Preview container (width adjusted by JS)
        div(id: "preview-container", class: "mx-auto border bg-white p-4 shadow", data: { preview_target: "container" }) do
          render Editors::Html::Preview.new resource: @document
        end
      end
    end
  end
end
