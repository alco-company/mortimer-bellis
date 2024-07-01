module Calendarable
  extend ActiveSupport::Concern

  included do
    has_many :calendars, as: :calendarable, dependent: :destroy

    after_save :create_calendar

    def create_calendar
      if self.calendars.empty?
        acc = (self.class == Account) ? self : self.account
        self.calendars.create(account: acc, name: self.name)
      end
    end
  end

  class_methods do
  end
end
