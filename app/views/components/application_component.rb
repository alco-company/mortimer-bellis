# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  def superadmin
    Current.user&.superadmin?
  end

  def say(msg, level = :info)
    Rails.logger.send(level, "-----------------")
    Rails.logger.send(level, msg)
    Rails.logger.send(level, "-----------------")
  end
end
