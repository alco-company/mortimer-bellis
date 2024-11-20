module TimeMaterialStateable
  extend ActiveSupport::Concern

  included do
    enum :state, {
      draft:                0,
      active:               1,
      paused:               2,
      done:                 3,
      pushed_to_erp:        4,
      cannot_be_pushed:     5,
      archived:           99
    }
    scope :by_state, ->(state) { where("state = ?", state) if state.present? }
    scope :archived, ->() { where(state: 99) }
  end

  class_methods do
    def time_material_states
      states.keys.collect { |k| [ k, I18n.t("time_material.states.#{k}") ] }
    end
  end
end
