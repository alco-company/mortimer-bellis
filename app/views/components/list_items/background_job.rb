class ListItems::BackgroundJob < ListItems::ListItem
  # :user_id
  # :state
  # :job_klass
  # :params
  # :schedule
  # :next_run_at
  # :job_id


  def show_matter_link
    div(class: "flex flex-row items-center") do
      show_matter_mugshot
      if user.global_queries?
        span(class: "hidden md:inline text-xs mr-2") { show_resource_link(resource: resource.tenant) }
      end
      span(class: "md:inline text-xs truncate") do
        link_to(resource_url,
          class: "truncate hover:underline inline grow flex-nowrap",
          data: { turbo_action: "advance", turbo_frame: "form" },
          tabindex: -1) do
          span(class: "2xs:hidden") { show_secondary_info }
          plain "%s %s %s" % [ resource.schedule, resource.job_id, resource.params ]
        end
      end
    end
  end

  def show_secondary_info
    p(class: "text-sm font-medium text-gray-900 dark:text-white") do
      plain "%s %s" % [ resource.state, resource.next_run_at ]
    end
  end
end
