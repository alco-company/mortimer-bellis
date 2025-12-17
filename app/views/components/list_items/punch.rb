class ListItems::Punch < ListItems::ListItem
  # tenant_id
  # user_id
  # punch_clock_id
  # punched_at
  # state
  # remote_ip
  # created_at
  # updated_at
  # punch_card_id
  # comment

  def show_secondary_info
    p(class: "text-sm font-medium text-gray-900 dark:text-white") do
      plain "%s %s " % [ resource.punch_clock&.name, resource.state ]
    end
  end
end
