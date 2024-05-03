class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include ExportCsv

  #
  # extend this method on the model to define the field formats
  # its a callback from the superform when rendering the form
  # (in non-editable mode, the form will render the field value using this method)
  # see app/views/forms/application_form.rb#row
  #
  def field_formats(key)
    case key
    when :updated_at, :created_at, :punched_at, :last_punched_at;   :datetime
    when :birthday, :hired_at, :punches_settled_at;                 :date
    else; nil
    end
  end


  def say(msg, level = :info)
    Rails.logger.send(level, "-----------------")
    Rails.logger.send(level, msg)
    Rails.logger.send(level, "-----------------")
  end


  def self.say(msg, level = :info)
    Rails.logger.send(level, "-----------------")
    Rails.logger.send(level, msg)
    Rails.logger.send(level, "-----------------")
  end
end
