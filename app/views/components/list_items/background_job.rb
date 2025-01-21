class ListItems::BackgroundJob < ListItems::ListItem
  # :user_id
  # :state
  # :job_klass
  # :params
  # :schedule
  # :next_run_at
  # :job_id


  def show_matter_link
    show_matter_mugshot
    if Current.user.global_queries?
      span(class: "hidden md:inline text-xs mr-2") { show_resource_link(resource.tenant) }
    end
    link_to(resource_url,
      class: "truncate hover:underline",
      data: { turbo_action: "advance", turbo_frame: "form" },
      tabindex: -1) do
      span(class: "2xs:hidden") { show_secondary_info }
      plain "%s %s %s" % [ resource.schedule, resource.job_id, resource.params ]
    end
  end

  def show_secondary_info
    plain "%s %s" % [ resource.state, resource.next_run_at ]
  end
end
