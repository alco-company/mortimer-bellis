class MortimerFooter < ApplicationComponent
  attr_reader :request, :platform

  def initialize(request:, platform: "desktop", &block)
    @request = request
    @platform = platform
  end

  def view_template(&block)
    footer(
      class:
        %(w-full fixed bottom-[0px] z-40 bg-slate-100 opaque-5)
    ) do
      div(
        class:
          "max-w-full lg:max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 mb-2"
      ) do
        div(
          class:
            "border-gray-200 py-2 text-xs text-gray-400 text-center sm:text-left text-nowrap"
        ) do
          span(class: "inline text-nowrap") do
            plain "© 2018-#{DateTime.current.year} &nbsp;&nbsp;MORTIMER&nbsp;&nbsp;".html_safe
          end
          span(class: "text-nowrap inline") { t(:all_rights_reserved) }
          if Rails.env.local?
            span(class: "inline text-green-900") do
              begin
                plain platform
              rescue StandardError
                "N/A"
              end
            end
          end
        end
      end
    end
  end
end
