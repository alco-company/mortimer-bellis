class PunchClockProfile < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTag
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField

  attr_accessor :user

  def initialize(user: nil)
    @user = user || false
  end

  def view_template(&block)
    div(id: "mortimer_form") do
      render User.profile(user, helpers.pos_user_url(api_key: user.access_token))
    end
  end

  # def action_buttons
  #   div(class: "px-4 mt-6 mb-24 sm:mb-12 flex items-center justify-start gap-x-2") do
  #     whitespace
  #     button(
  #       type: "button",
  #       data: { action: "click->pos-employee#clearForm" },
  #       class: "mort-btn-cancel"
  #     ) { helpers.t("cancel") }
  #     whitespace
  #     button(
  #       type: "submit",
  #       class:
  #         "mort-btn-primary"
  #     ) { helpers.t("save") }
  #   end
  # end
end
