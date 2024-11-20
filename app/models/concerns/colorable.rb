module Colorable
  extend ActiveSupport::Concern

  class Color
    attr_accessor :value, :id
    def initialize(color)
      @value = I18n.t("colors.#{color}")
      @id = "border-#{color}-500"
    end
  end
  COLORS = %w[gray red fuchsia blue green yellow indigo orange lime cyan pink amber stone].collect { |color| Color.new(color) }.freeze
  # tailwindcss colors
  #
  # border-gray-500
  # border-red-500
  # border-fuchsia-500
  # border-sky-200
  # border-green-500
  # border-yellow-500
  # border-sky-500
  # border-orange-500
  # border-lime-500
  # border-cyan-500
  # border-pink-500
  # border-amber-500
  # border-stone-500



  included do
  end

  class_methods do
    def colors(key = 1)
      return COLORS if key == 1
      COLORS.filter { |k| k if k.id == key }[0].value
    rescue
      ""
    end
  end
end
