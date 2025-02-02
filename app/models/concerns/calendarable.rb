module Calendarable
  extend ActiveSupport::Concern

  included do
    has_many :calendars, as: :calendarable, dependent: :destroy

    after_save :create_calendar

    def create_calendar
      if self.calendars.empty?
        acc = (self.class == Tenant) ? self : self.tenant
        self.calendars.create(tenant: acc, name: self.name)
      end
    end
  end

  class_methods do
  end
end
