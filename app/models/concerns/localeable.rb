module Localeable
  extend ActiveSupport::Concern

  class Locale
    attr_accessor :value, :id
    def initialize(locale)
      @value = I18n.t("locale.#{locale}")
      @id = locale
    end
  end
  LOCALES = %w[da en de].collect { |color| Locale.new(color) }.freeze

  included do
  end

  class_methods do
    def locales(key = 1)
      return LOCALES if key == 1
      LOCALES.filter { |k| k if k.id == key }[0].value
    rescue
      ""
    end
  end
end
