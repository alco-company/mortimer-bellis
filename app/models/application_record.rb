COLORS = %w[gray red fuchsia blue green yellow indigo orange lime cyan pink amber stone].collect { |color| { value: I18n.t("colors.#{color}"), id: "border-#{color}-500" } }.freeze
# tailwindcss colors
#
# border-gray-500
# border-red-500
# border-fuchsia-500
# border-blue-500
# border-green-500
# border-yellow-500
# border-indigo-500
# border-orange-500
# border-lime-500
# border-cyan-500
# border-pink-500
# border-amber-500
# border-stone-500

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
    when /\./;                                                      :association
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


  def self.colors(key = nil)
    return COLORS if key.nil?
    COLORS.filter { |k| k[:id] == key }[0][:value]
  rescue
    key
  end
end
