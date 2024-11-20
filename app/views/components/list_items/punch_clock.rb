class ListItems::PunchClock < ListItems::ListItem
  def show_recipient_link
    link_to pos_punch_clock_url(resource, api_key: resource.access_token), class: "hover:underline" do
      plain "Kiosk link for %s" % resource.name
    end
  end

  def show_left_mugshot
    # mugshot(resource, css: "hidden sm:block h-12 w-12 flex-none rounded-full bg-gray-50")
  end

  def show_matter_mugshot
    # mugshot(resource, css: "sm:hidden mr-2 h-5 w-5 flex-none rounded-full bg-gray-50")
  end

  def show_secondary_info
    plain "%s %s" % [ resource.location.name, resource.ip_addr ]
  end
end
