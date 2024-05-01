class MortimerController < ApplicationController
  # This is essential to all controllers which is
  # why it gets included on the ApplicationController
  # and not the MortimerController - by inheriting
  # from the ApplicationController you may skip some of the
  # automagic - but authentication cannot be skipped; you can
  # override this, however, on controllers by calling
  # skip_before_action :authenticate_user!
  #
  include Authentication

  include Resourceable
  include DefaultActions
  include TimezoneLocale
end
