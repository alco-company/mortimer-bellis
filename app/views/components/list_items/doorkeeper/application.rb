class ListItems::Doorkeeper::Application < ListItems::ListItem
  def show_recipient_link
    p(class: "text-sm/6 font-semibold text-gray-900 dark:text-white") do
      link_to resource_url, class: "hover:underline" do
        plain resource.name
      end
    end
  end

  def show_left_mugshot
    div(class: "flex items-center") do
      input(type: "checkbox", name: "batch[ids][]", value: resource.id, class: "hidden batch mort-form-checkbox mr-2")
      # mugshot(resource.user, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
    end
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    p(class: "text-sm font-medium text-gray-900 dark:text-white") do
      plain resource.uid
    end
  end
end
