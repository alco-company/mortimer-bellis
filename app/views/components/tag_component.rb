# frozen_string_literal: true

class TagComponent < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(resource:, field:, resources: nil, search: nil, value: [], show_label: true, field_class: "mort-field", label_class: "text-gray-400", value_class: "mr-5", editable: true)
    @resource = resource
    @field = field
    @resources = resources
    @show_label = show_label
    @field_class = field_class
    @label_class = label_class
    @value_class = value_class
    @search = search.nil? ? "" : search
    @editable = editable
    @value = value
    @ids = value.empty? ? "" : value.map(&:id).join(",")
  end

  def view_template
    turbo_frame_tag "#{Current.get_user.id}_tag" do
      div(class: "mort-field", data: { controller: "tag" }) do
        input(type: "hidden",
          name: resource_field("%s[%s]"),
          id: resource_field,
          value: @ids,
          data: { tag_target: "output" })
        @editable ? editable_view : show_view
      end
    end
  end

  def show_view
    div do
      label_container
      plain @resource.send @field
    end
  end

  def editable_view
    div(class: "flex flex-col", data: { action: "click->tag#focus" }) do
      label_container
      div(class: "inline-flex w-full rounded-md border-0 bg-white py-1.5 pl-1 text-gray-900 shadow-xs ring-1 ring-inset ring-gray-300 ") do
        selected_container
        # editor_field
      end
      div(class: "relativ") do
        render_tags_list
      end
    end
  end

  def resource_field(joined = "%s_%s")
    joined % [ @resource.class.to_s.underscore, @field.to_s.underscore ]
  end

  def label_container
    return unless @show_label
    label(for: resource_field, class: @label_class) do
      span do
        plain I18n.t("activerecord.attributes.#{ resource_field("%s.%s") }")
      end
    end
  end

  def selected_container
    div(id: resource_field("%s-%s-selected-container"), data: { tag_target: "selectedTags" }, class: "flex flex-wrap") do
      @value.each do |tag|
        span(class: "flex items-center") do
          a(href: "#", data: { action: "click->tag#removeTag", id: tag.id }, class: "ml-0.5 mb-0.5") do
            span(class: "flex items-center bg-gray-200 text-gray-700 px-2 py-1 rounded-md text-sm") do
              span { tag.name }
              render Icons::Cancel.new(css: "ml-2 h-4 w-4 text-gray-400")
            end
          end
        end
      end
      editor_field
    end
  end

  def editor_field
    span(contenteditable: true,
      data: {
        tag_target: "input",
        action: "keydown->tag#keydown keyup->tag#keyup focus->tag#focus",
        placeholder: I18n.t("components.tag.#{@field}")
      },
      style: "border: none; outline: none;",
      class: "grow ml-0.5 px-1",
      name: resource_field("%s[%s]-input"),
      id: resource_field("%s_%s-input")) { @search.html_safe }
    # span(contenteditable: "true",
    #   autocorrect: "off",
    #   autocapitalize: false,
    #   role: "textbox",
    #   class: "tag-input",
    #   aria: {
    #     autocomplete: "off",
    #     multiline: false,
    #     placeholder: I18n.t("components.tag.#{@field}")
    #   },
    #   data: {
    #     tag_target: "input",
    #     action: "keydown->tag#keydown keyup->tag#keyup focus->tag#focus",
    #     placeholder: I18n.t("components.tag.#{@field}")
    #   },
    #   name: resource_field("%s[%s]-input"),
    #   id: resource_field("%s_%s-input")) { @search.html_safe }
  end

  def render_tags_list
    return if @resources.nil? or (@resources.empty? && @search == "")

    div(id: resource_field("%s-%s-lookup-container"),
      data: { tag_target: "tagList" },
      class: "py-2 absolute z-10 mt-0.5 mort-form-text min-h-[50px] max-w-sm shadow-md") do
      div(class: "tag-list-item current-tag-list-item cursor-pointer bg-sky-100 hover:bg-sky-200") do
        a(href: "#", data: { action: "click->tag#addTag", id: "0" }, class: "px-2") do
          plain I18n.t("components.tag.add_tag")
        end
      end if @resources.empty? || @resources.filter { |tag| tag.name == @search }.empty?
      @resources.each do |tag|
        next if @value.include? tag
        div(class: "tag-list-item cursor-pointer hover:bg-sky-200") do
          a(href: "#", data: { action: "click->tag#pick", id: tag.id }, class: "px-2") do
            plain tag.name
          end
        end
      end
    end
  end
end
