class TimeMaterialItem < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::DOMID
  # include Phlex::Rails::Helpers::Routes

  attr_reader :resource

  def initialize(resource:)
    @resource = resource
  end

  def view_template
    li(id: (dom_id resource), class: "flex justify-between bg-gray-50 mt-1 rounded-md px-2 gap-x-4 gap-y-2 py-3") do
      div(class: "w-3/4 flex grow flex-col") do
        # comment do
        #   %(TODO add mugshots for time_materials <img class="h-12 w-12 flex-none rounded-full bg-gray-50" src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80" alt="">)
        # end
        p(class: "flex-nowrap mort-tm-line-customer h-7 leading-6 truncate") do
          helpers.show_time_material_customer_link(resource: resource)
        end
        p(class: "grow mort-tm-line-product leading-5 truncate") do
          helpers.show_time_material_resource_link(resource: resource)
          if helpers.global_queries? Current.user
            span(class: "text-xs") { helpers.show_resource_link(resource: resource.tenant) }
          end
        end
      end
      div(class: "w-1/4 flex grow-0 flex-col items-end text-right") do
        div(class: "flex items-center gap-x-2") do
          div(class: "") do
            p(class: "mort-tm-line-customer leading-6 h-7") do
              span(
                class:
                  %(#{resource.is_invoice? ? "" : "hidden"} w-fit inline-flex items-center rounded-md bg-green-50 px-1 xs:px-2 py-0 xs:py-0.5 text-2xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20 truncate)
              ) do
                plain " f "
                span(class: "hidden sm:inline") { "akturérbar" }
              end
              span(class: (resource.is_free? ? "text-red-500" : "")) do
                plain resource.time
                plain " t"
              end
            end
            p(class: "mort-tm-line-product float-right leading-5 flex items-center") do
              render Icons::Lock if resource.pushed_to_erp?
              span(class: "truncate") do
                plain I18n.l resource.created_at, format: :date
              end
            end
          end
          helpers.render_contextmenu resource: resource,
            cls: "relative flex-none",
            turbo_frame: "form",
            resource_class: TimeMaterial,
            alter: true,
            links: [ edit_time_material_url(resource), time_material_url(resource) ]
        end
      end
    end
  end
end
