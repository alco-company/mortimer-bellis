module Countryable
  extend ActiveSupport::Concern

  class Country
    attr_accessor :value, :id
    def initialize(country)
      @value = I18n.t("country.#{country}")
      @id = country.upcase
    end
  end
  COUNTRIES = %w[dk se de].collect { |country| Country.new(country) }.freeze

  included do
  end

  class_methods do
    def country_keys(key = 1)
      return COUNTRIES if key == 1
      COUNTRIES.filter { |k| k if k.id == key }[0].value
    rescue
      ""
    end
  end
end
