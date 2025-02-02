class ListItems::Task < ListItems::ListItem
  # tenant_id
  # name
  # color

  def show_left_mugshot
    # mugshot(resource, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
    span(class: "mr-4") { resource.priority }
  end

  def show_secondary_info
    plain "%s " % [ resource.completed_at&.strftime("%Y-%m-%d") ]
  end
end
