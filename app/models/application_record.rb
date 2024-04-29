require 'csv'

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # 
  # extend this method on the model to define the field formats
  # its a callback from the superform when rendering the form
  # (in non-editable mode, the form will render the field value using this method)
  # see app/views/forms/application_form.rb#row
  #
  def field_formats(key)
    case key
    when :updated_at, :created_at, :last_punched_at;  :datetime
    when :birthday, :hired_at, :punches_settled_at;   :date
    else; nil
    end
  end

  #
  # generic method to return a dataset for a model
  # as CSV
  #
  def self.to_csv(resources)
    CSV.generate do |csv|
      csv << column_names
      resources.each do |resource|
        csv << resource.attributes.values_at(*column_names)
      end
    end
  end
end
