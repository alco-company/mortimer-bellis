#
#
# handles the settings
#
module Setable
  extend ActiveSupport::Concern

  included do
    has_many :settings, dependent: :destroy
  end

  class_methods do
  end
end
