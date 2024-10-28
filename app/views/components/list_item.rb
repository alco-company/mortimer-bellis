class ListItem < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::DOMID
  # include Phlex::Rails::Helpers::Routes

  attr_reader :resource

  def initialize(resource:)
    @resource = resource
  end

  def view_template
    div(id: (dom_id resource), class: "flex justify-between gap-x-6 mb-1 px-2 py-5 bg-gray-50 #{ background }") do
      div(class: "flex min-w-0 gap-x-4") do
        span { helpers.show_resource_mugshot(resource: resource) }
        div(class: "min-w-0 flex-auto") do
          p(class: "text-sm font-semibold leading-6 text-gray-900 truncate") do
            show_recipient_link
          end
          p(class: "mt-1 flex text-xs leading-5 text-gray-500") do
            show_matter_link
          end
        end
      end
      div(class: "flex shrink-0 items-center gap-x-6") do
        div(class: "hidden 2xs:flex 2xs:flex-col 2xs:items-end") do
          p(class: "text-sm leading-6 text-gray-900") do
            show_secondary_info
          end
          p(class: "mt-1 text-xs leading-5 text-gray-500 flex items-center") do
            show_time_info
          end
        end
        render Contextmenu.new resource: resource,
          cls: "relative flex-none",
          turbo_frame: "form",
          resource_class: TimeMaterial,
          alter: true,
          links: [ edit_time_material_url(resource), time_material_url(resource) ]
      end
    end
  end

  def say_how_much
    u = resource.unit.blank? ? "" : unsafe_raw(I18n.t("time_material.responsive_units.#{resource.unit}"))
    if resource.quantity.blank?
      resource.time.blank? ? "" : span(class: "truncate") { "%s %s" % [ resource.time, u ] }
    else
      span(class: "truncate") { "%s %s" % [ resource.quantity, u ] }
    end
  end

  def background
    return "bg-gray-50" if !resource.pushed_to_erp? and !resource.cannot_be_pushed?
    return "bg-gray-500/20" if resource.pushed_to_erp?
    return "bg-yellow-400/50" if resource.cannot_be_pushed?
    ""
  end

  def show_recipient_link
    case resource.class.name
    when "TimeMaterial"; helpers.show_time_material_customer_link(resource: resource)
    end
  end

  def show_matter_link
    case resource.class.name
    when "TimeMaterial"
      span { helpers.user_mugshot(resource.user, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50") }
      if helpers.global_queries? Current.user
        span(class: "hidden md:inline text-xs") { helpers.show_resource_link(resource: resource.tenant) }
      end
      span(class: "2xs:hidden") { helpers.show_time_material_quantative resource: resource }
      span { helpers.show_time_material_resource_link(resource: resource) }
    end
  end

  def show_secondary_info
    case resource.class.name
    when "TimeMaterial"; helpers.show_time_material_quantative resource: resource
    end
  end

  def show_time_info
    case resource.class.name
    when "TimeMaterial"
      span(class: "hidden 2xs:inline-flex w-fit items-center rounded-md bg-green-50 mr-1 px-1 xs:px-2 py-0 xs:py-0.5 text-2xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20 truncate") do
        render Icons::Money.new(cls: "text-green-500 h-4 w-4")
        span(class: "hidden ml-2 md:inline") { I18n.t("time_material.billable") }
      end
      span(class: "truncate") do
        plain I18n.l resource.created_at, format: :date
      end
    end
  end
end
