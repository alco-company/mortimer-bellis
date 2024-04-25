class Team < ApplicationRecord
  include Accountable
  TEAM_COLORS = %w[border-red-700 border-blue-700 border-green-700 border-yellow-700 border-purple-700 border-orange-700 border-pink-700 border-brown-700 border-black-700]

  has_many :employees, dependent: :destroy
  # has_and_belongs_to_many :employees

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_team_color, ->(team_color) { where("team_color LIKE ?", "%#{team_color}%") if team_color.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_name(flt["name"])
      .by_team_color(flt["team_color"])
      .by_locale(flt["locale"])
      .by_time_zone(flt["time_zone"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Teams::Form.new resource, editable: editable
  end

  def self.colors
    TEAM_COLORS
  end

  # def color
  #   self.class.colors[id % self.class.colors.size]
  # end
end