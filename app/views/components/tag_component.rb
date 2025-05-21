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
      div(
        class: "mort-field",
        data: { controller: "tag" }) do
        input(type: "hidden",
          name: resource_field("%s[%s]"),
          id: resource_field,
          value: @ids,
          data: { tag_target: "output", context: @resource.class.to_s, field: @field.to_s })
        # @editable ? editable_view : show_view
        @editable ? edit_view : show_view
      end
    end
  end

  def edit_view
    div(data: { action: "click->tag#focus" }) do
      label_container
      # label(
      #   id: "listbox-label",
      #   class: "block text-sm/6 font-medium text-gray-900"
      # ) { "Assigned to" }
      div(class: "relative mt-2 mort-form-text") do
        selected_container
        render_tags_list
      end
    end
  end

  def show_view
    div do
      label_container
      plain @resource.send @field
    end
  end

  # def editable_view
  #   div(class: "flex flex-col", data: { action: "click->tag#focus" }) do
  #     label_container
  #     div(class: "inline-flex w-full rounded-md border-0 bg-white py-1.5 pl-1 text-gray-900 shadow-xs ring-1 ring-inset ring-gray-300 ") do
  #       selected_container
  #     end
  #     div(class: "relativ") do
  #       render_tags_list
  #     end
  #   end
  # end

  def resource_field(joined = "%s_%s")
    joined % [ @resource.class.to_s.underscore, @field.to_s.underscore ]
  end

  def label_container
    return unless @show_label
    label(
      id: "#{@field}-listbox-label",
      for: resource_field,
      class: @label_class) do
      span do
        plain I18n.t("activerecord.attributes.#{ resource_field("%s.%s") }")
      end
    end
  end

  def selected_container
    div(id: resource_field("%s-%s-selected-container"), data: { tag_target: "selectedTags" }, class: "flex flex-wrap w-full") do
      @value.each do |tag|
        span(class: "flex items-center") do
          a(href: "#", data: { action: "touchstart->tag#removeTag click->tag#removeTag", id: tag.id }, class: "ml-0.5 mb-0.5") do
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
        action: "keydown->tag#keydown keyup->tag#keyup focus->tag#focus blur->tag#blur",
        placeholder: I18n.t("components.tag.#{@field}")
      },
      style: "border: none; outline: none;",
      class: "grow ml-0.5 px-1",
      name: resource_field("%s[%s]-input"),
      id: resource_field("%s_%s-input")) { @search.html_safe }
  end

  # def render_tags_list
  #   return if @resources.nil? or (@resources.empty? && @search == "")

  #   div(id: resource_field("%s-%s-lookup-container"),
  #     data: { tag_target: "tagList" },
  #     class: "py-2 relative md:absolute top-0 bg-white z-10 mt-0.5 mort-form-text min-h-[50px] max-w-sm shadow-md") do
  #     div(data: { action: "touchstart->tag#addTag click->tag#addTag", id: "0" }, class: "flex tag-list-item current-tag-list-item cursor-pointer bg-sky-100 hover:bg-sky-200 h-[40px] items-center") do
  #       span(class: "px-2") do
  #         plain I18n.t("components.tag.add_tag")
  #       end
  #     end if @resources.empty? || @resources.filter { |tag| tag.name == @search }.empty?
  #     @resources.each do |tag|
  #       next if @value.include? tag
  #       div(data: { action: "touchstart->tag#pick click->tag#pick", id: tag.id }, class: "flex tag-list-item cursor-pointer hover:bg-sky-200 w-full h-[40px] items-center") do
  #         span(class: "px-2") do
  #           plain tag.name
  #         end
  #       end
  #     end
  #   end
  # end

  def render_tags_list
    return if @resources.nil? or (@resources.empty? && @search == "")
    ul(
      id: resource_field("%s-%s-lookup-container"),
      data: { tag_target: "tagList" },
      class:
        "absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black/5 focus:outline-hidden sm:text-sm",
      tabindex: "-1",
      role: "listbox",
      aria_labelledby: "#{@field}-listbox-label",
      aria_activedescendant: "listbox-option-3"
    ) do
      comment do
        %(Select option, manage highlight styles based on mouseenter/mouseleave and keyboard navigation. Highlighted: "bg-indigo-600 text-white outline-hidden", Not Highlighted: "text-gray-900")
      end
      li(
        data: { action: "touchstart->tag#addTag click->tag#addTag", id: "0" },
        class:
          "relative current-tag-list-item cursor-pointer bg-sky-100 hover:bg-sky-200 py-2 pr-9 pl-3 text-gray-900 select-none",
        id: "listbox-option-0",
        role: "option"
      ) do
        comment do
          %(Selected: "font-semibold", Not Selected: "font-normal")
        end
        span(class: "block truncate font-normal") { I18n.t("components.tag.add_tag") }
      end if @resources.empty? || @resources.filter { |tag| tag.name == @search }.empty?

      @resources.each do |tag|
        next if @value.include? tag
        li(
          data: { action: "touchstart->tag#pick click->tag#pick", id: tag.id },
          class:
            "relative cursor-pointer hover:bg-sky-200 py-2 pr-9 pl-3 text-gray-900 select-none",
          id: "listbox-option-#{tag.id}",
          role: "option"
        ) do
          comment do
            %(Selected: "font-semibold", Not Selected: "font-normal")
          end
          span(class: "block truncate font-normal") { show_tag_name(tag) }
        end
      end
    end
  end

  def show_tag_name(tag)
    @search =~ /:/ ?
      "%s:%s" % [ tag.category, tag.name ] :
      tag.name
  end
end
