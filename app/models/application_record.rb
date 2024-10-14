class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include ExportCsv
  include ExportPdf

  #
  # extend this method on the model to define the field formats
  # its a callback from the superform when rendering the form
  # (in non-editable mode, the form will render the field value using this method)
  # see app/views/forms/application_form.rb#row
  #
  def field_formats(key)
    case key
    when :mugshot, :logo;                                           :file
    when :updated_at, :created_at, :punched_at, :last_punched_at;   :datetime
    when :birthday, :hired_at, :punches_settled_at;                 :date
    when :state;                                                    :enum
    when /\./;                                                      :association
    else; nil
    end
  end

  # implement this method on model that has mugshots
  def has_mugshot?
    false
  end

  # implement this method on model that has one/more photos
  def mugshot
    raise "implement this method on the model if mugshot exist!" if has_mugshot?
  end


  def list_item(links: [])
    # TimeMaterialDetailItem.new(item: self, links: links)
    raise "implement this method on the model in order to list_item!"
  end

  def self.form(resource, editable = true)
    # Locations::Form.new resource, editable: editable
    raise "implement this method on the model in order to show/edit post!"
  end

  def self.ordered(resources, field, direction = :desc)
    resources.order(field => direction)
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
