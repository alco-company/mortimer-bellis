class ListItems::ListItem < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::ImageTag

  attr_reader :resource, :params, :user, :format

  # links is an array of links to be rendered in the contextmenu - edit, delete/show
  def initialize(resource:, params:, user: nil, format: :html)
    @resource = resource
    @params = params
    @user = user
    @format = format
  end

  def view_template
    case format
    when :html        ; html_list
    when :pdf         ; pdf_list
    when :pdf_header  ; pdf_list_header
    else              ; raise "Unsupported format"
    end
  end

  def html_list
    div(id: (dom_id resource), class: "list_item relative bg-gray-50", data: { list_target: "item", controller: "list-item" }) do
      div(class: "flex grow min-w-0 gap-x-4") do
        show_left_mugshot
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
        render_context_menu
      end
    end
  end

  def pdf_list
    tr do
      td { show_recipient_link }
      td { show_matter_link }
      td { show_secondary_info }
      td { show_time_info }
    end
  end

  def pdf_list_header
    thead(class: "flex items-center justify-between gap-x-6 py-5") do
      th(class: "text-sm font-semibold leading-6 text-gray-900") { "Recipient" }
      th(class: "text-sm font-semibold leading-6 text-gray-900") { "Matter" }
      th(class: "text-sm font-semibold leading-6 text-gray-900") { "Secondary Info" }
      th(class: "text-sm font-semibold leading-6 text-gray-900") { "Time Info" }
    end
  end


  def show_recipient_link
    link_to resource_url, data: { turbo_action: "advance", turbo_frame: "form", tabindex: "-1" }, class: "hover:underline" do
      plain resource.name
    end
  end

  def show_matter_link
    show_matter_mugshot
    if user&.global_queries? && resource.respond_to?(:tenant)
      span(class: "hidden md:inline text-xs mr-2 truncate ") { show_resource_link(resource: resource.tenant) }
    end unless resource_class == Tenant
    span(class: "md:inline text-xs truncate") do
      link_to(resource_url,
        class: "truncate hover:underline inline grow flex-nowrap",
        data: { turbo_action: "advance", turbo_frame: "form" },
        tabindex: -1) do
        span(class: "2xs:hidden") { show_secondary_info }
        plain resource.name
      end
    end
  end

  def show_secondary_info
    plain "implement show_secondary_info"
  end
  #
  # show_secondary_info is placed in the upper right corner of the ListItem
  #
  # def show_secondary_info(resource:)
  #   case resource.class.name
  #   when "User"
  #   when "TimeMaterial"; show_time_material_quantative resource: resource
  #   else; ""
  #   end
  # end



  def show_time_info
    span(class: "truncate") do
      plain l(resource.created_at, format: :date)
    end
  end

  def show_left_mugshot
    div(class: "flex items-center") do
      input(type: "checkbox", name: "batch[ids][]", value: resource.id, id: "batch_#{resource.id}", class: "hidden batch mort-form-checkbox mr-2")
      mugshot(resource.user, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
    end
  end

  def show_matter_mugshot
    mugshot(resource.user, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def mugshot(item, size: nil, css: "h-6 w-6 rounded-full bg-gray-50")
    return "" if item.blank?
    size = size.blank? ? "40x40!" : size
    if (item.mugshot.attached? rescue false)
      image_tag(url_for(item.mugshot), class: css)
    else
      # size.gsub!("x", "/") if size =~ /x/
      # size.gsub!("!", "") if size =~ /!/
      image_tag("icons8-customer-64.png", class: css)
    end
  rescue
    image_tag("icons8-customer-64.png", class: css)
  end

  def render_context_menu(cls = "relative flex-none")
    render Contextmenu.new resource: resource,
      cls: cls,
      turbo_frame: "form",
      resource_class: resource_class,
      alter: true,
      links: [ edit_resource_url, resource_url ],
      user: user
  end

  #
  # if this update goes to a channel subscriber
  # who has this user_id
  # - otherwise return false
  def this_user?(user_id)
    return false if Current.user.blank?
    resource.user_id == user_id && user_id == user.id
  end
end
