module TaskStateable
  extend ActiveSupport::Concern

  included do
    enum :state, {
      draft:                0,
      active:               1,
      paused:               2,
      done:                 3,
      archived:           99
    }
    scope :by_state, ->(state) { where("state = ?", state) if state.present? }
  end

  class_methods do
    def task_states
      states.keys.collect { |k| [ k, I18n.t("task.states.#{k}") ] }
    end
  end
end
