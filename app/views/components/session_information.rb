class SessionInformation < ApplicationComponent
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def view_template
    dt(class: "sr-only") { "sign in information" }
    dd(class: "mt-3 flex items-center text-xs font-light text-gray-500 sm:mr-6 sm:mt-0") do
      remains = ((Current.user.last_sign_in_at + Current.get_tenant.get_session_timeout) - Time.now).seconds
      days, hours, minutes, seconds = TimeMaterial.new.calc_hrs_minutes(remains)
      str = case true
      when minutes==0;t("session_done_shortly", seconds: seconds)
      when hours==0;t("session_done_minutes", minutes: minutes)
      when days==0;t("session_done_hrs", hours: hours, minutes: minutes)
      else t("session_done_days", days: days, hours: hours, minutes: minutes)
      end
      p { t("sign_in_info", signin: l(Current.user.last_sign_in_at, format: :long), session_done: str) }
    end
  end
end
