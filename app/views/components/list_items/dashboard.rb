class ListItems::Dashboard < ListItems::ListItem
  # tenant_id
  # feed
  # last_feed
  # last_feed_at
  # created_at
  # updated_at

  def show_left_mugshot
    # mugshot(resource, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain "%s %s" % [ resource.feed, resource.last_feed_at ]
  end
end
