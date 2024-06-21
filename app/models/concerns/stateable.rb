WORK_STATES = [
  [ "out",  I18n.t("punch.out") ],
  [ "in",  I18n.t("punch.in") ],
  [ "break",  I18n.t("punch.break") ],
  [ "sick",  I18n.t("punch.sick") ],
  [ "iam_sick",  I18n.t("punch.iam_sick") ],
  [ "child_sick",  I18n.t("punch.child_sick") ],
  [ "nursing_sick",  I18n.t("punch.nursing_sick") ],
  [ "lost_work_sick",  I18n.t("punch.lost_work_sick") ],
  [ "p56_sick",  I18n.t("punch.p56_sick") ],
  [ "free",  I18n.t("punch.free") ],
  [ "rr_free", I18n.t("punch.rr_free") ],
  [ "senior_free", I18n.t("punch.senior_free") ],
  [ "unpaid_free", I18n.t("punch.unpaid_free") ],
  [ "maternity_free", I18n.t("punch.maternity_free") ],
  [ "leave_free", I18n.t("punch.leave_free") ],
  [ "archived", I18n.t("punch.archived") ]
]
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
      leave_free:         14,
      archived:           99
      # "ABSENT" => 3, "SICK" => 4, "VACATION" => 5, "HOLIDAY" => 6, "WORKING" => 7, "BUSY" => 8, "FREE" => 9, "UNAVAILABLE" => 10, "AVAILABLE" => 11, "ONLINE" => 12, "OFFLINE" => 13, "AWAY" => 14, "DND" => 15, "CALL" => 16, "MEETING" => 17, "LUNCH" => 18, "BREAK" => 19, "CUSTOM" => 20
    }
    scope :by_state, ->(state) { where("state = ?", state) if state.present? }
    scope :archived, ->() { where(state: 99) }
  end

  class_methods do
  end
end
