class AccountsController < ApplicationController
  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:account).permit(:name, :email, :pp_identification, :locale, :time_zone)
    end
end
