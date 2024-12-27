class Employees::Profile < ApplicationForm
  def view_template(&)
    div(class: "p-4 sm:p-1") do
      mortimer_version_locale_time_zone
      h2(class: "text-base font-semibold leading-7 text-gray-900") do
        "Profile"
      end
      p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
        "This information will be displayed publicly so be careful what you share."
      end
      div(
        class:
          "mt-10 space-y-8 border-b border-gray-900/10 pb-12 sm:space-y-0 sm:divide-y sm:divide-gray-900/10 sm:border-t sm:pb-0"
      ) do
        row field(:name).input()
        row field(:description).input()
        row field(:mugshot).file(class: "mort-form-file")
      end
      h2(class: "text-base font-semibold leading-7 text-gray-900") do
        "Personal Information"
      end
      p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
        "This information will only be used to contact you and will not be displayed publicly. You can change your personal information at any time."
      end
      div(
        class:
          "mt-10 space-y-8 border-b border-gray-900/10 pb-12 sm:space-y-0 sm:divide-y sm:divide-gray-900/10 sm:border-t sm:pb-0"
      ) do
        row field(:email).input()
        row field(:cell_phone).input()
        row field(:birthday).date(class: "mort-form-text")
        row field(:locale).select(User.locales, prompt: I18n.t(".select_user_locale"), class: "mort-form-text")
        row field(:time_zone).select(ActiveSupport::TimeZone.all.collect { |tz| [ "(GMT#{ActiveSupport::TimeZone.seconds_to_utc_offset(tz.utc_offset)}) #{tz.name}", tz.tzinfo.name ] }, class: "mort-form-text")
      end
    end
  end

  def mortimer_version_locale_time_zone
    p(class: "text-xs font-thin pb-3") { "version: #{ENV["MORTIMER_VERSION"]} #{model.locale}/#{model.time_zone}" }
  end
end
