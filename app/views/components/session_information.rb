class SessionInformation < ApplicationComponent
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def view_template
    dt(class: "sr-only") { "sign in information" }
    dd(class: "mt-3 flex items-center text-xs font-light text-gray-500 sm:mr-6 sm:mt-0") do
      remains = ((Current.user.last_sign_in_at + 7.days) - Time.now).seconds
      days, hours, minutes, seconds = TimeMaterial.new.calc_hrs_minutes(remains)
      str = case true
      when minutes==0;I18n.t("session_done_shortly", seconds: seconds)
      when hours==0;I18n.t("session_done_minutes", minutes: minutes)
      when days==0;I18n.t("session_done_hrs", hours: hours, minutes: minutes)
      else I18n.t("session_done_days", days: days, hours: hours, minutes: minutes)
      end
      p { I18n.t("sign_in_info", signin: I18n.l(Current.user.last_sign_in_at, format: :long), session_done: str) }
    end
  end
end
