module Stateable
  extend ActiveSupport::Concern

  included do
    enum :state, {
      out:                0,
      in:                 1,
      break:              2,
      sick:               3,
      iam_sick:           4,
      child_sick:         5,
      nursing_sick:       6,
      lost_work_sick:     7,
      p56_sick:           8,
      free:               9,
      rr_free:            10,  # Rest & Relaxation
      senior_free:        11,
      unpaid_free:        12,
      maternity_free:     13,
      leave_free:         14
      # "ABSENT" => 3, "SICK" => 4, "VACATION" => 5, "HOLIDAY" => 6, "WORKING" => 7, "BUSY" => 8, "FREE" => 9, "UNAVAILABLE" => 10, "AVAILABLE" => 11, "ONLINE" => 12, "OFFLINE" => 13, "AWAY" => 14, "DND" => 15, "CALL" => 16, "MEETING" => 17, "LUNCH" => 18, "BREAK" => 19, "CUSTOM" => 20 
    }
    scope :by_state, ->(state) { where("state = ?", state) if state.present? }
  end

  class_methods do
  end
end
