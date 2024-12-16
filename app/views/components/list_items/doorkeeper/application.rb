class ListItems::Doorkeeper::Application < ListItems::ListItem
  def show_recipient_link
    link_to resource_url, class: "hover:underline" do
      plain resource.name
    end
  end

  def show_left_mugshot
    # mugshot(resource, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain resource.uid
  end
end
