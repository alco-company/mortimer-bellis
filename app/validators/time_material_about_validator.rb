class TimeMaterialAboutValidator < ActiveModel::Validator
  attr_accessor :shared

  def validate(record)
    @shared = ""
    if options[:fields].any? { |field| issues(record, field) }
      if @shared.blank?
        record.errors.add field, ApplicationController.helpers.tl("one_of_the_fields_must_be_filled")
        return false
      end
      true

    end
  end

  def issues(record, field)
    unless record.send(field).blank?
      @shared = record.send(field)
    end
  end
end
