# WORK_STATES = [
#   [ "out",  I18n.t("punch.out") ],
# ...
#   [ "archived", I18n.t("punch.archived") ]
# ]

# WORK_STATE_H = {
#   "out" =>  I18n.t("punch.out"),
# ...
#   "archived" => I18n.t("punch.archived")
# }

module TimeMaterialStateable
  extend ActiveSupport::Concern

  included do
    enum :state, {
      draft:                0,
      active:               1,
      paused:               2,
      done:                 3,
      pushed_to_erp:        4,
      archived:           99
    }
    scope :by_state, ->(state) { where("state = ?", state) if state.present? }
    scope :archived, ->() { where(state: 99) }
  end

  class_methods do
  end
end
