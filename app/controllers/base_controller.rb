class BaseController < ApplicationController
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  layout "application"
  # layout "vertical_menu_application"
  # TODO - make Phlex layouts work
  # layout -> { ApplicationLayout }

  # This is essential to all controllers which is
  # why it gets included on the BaseController - by inheriting
  # from the ApplicationController you may skip it!
  # or you can this,on controllers by calling
  # skip_before_action :authenticate_user!
  # skip_before_action :ensure_tenanted_user
  #
  include Authentication
  #
  # This next include makes sure
  # that users do sign in at least every
  # 7 days
  include SessionGuard
  #
  #
  #
  include Pagy::Backend
  #
  # the COUNT(*) can be avoided by implementing the following
  # method on the model
  # def pagy_get_count(collection, vars)
  #   collection.respond_to?(:count_documents) ? collection.count_documents : super
  # end
end
