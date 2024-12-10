class Oauth::Application < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application

  self.table_name = "oauth_applications"

  def self.form(resource:, editable: true)
    Oauth::Application::Form.new resource: resource, editable: editable
  end
end
