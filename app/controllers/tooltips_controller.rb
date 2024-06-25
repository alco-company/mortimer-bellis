class TooltipsController < ApplicationController
  def show
    @punch = Punch.find(params[:punch_id])
  end
end
