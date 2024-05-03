class Stats < ApplicationComponent

  attr_accessor :stats

  def initialize title:, stats: nil 
    @title = title
    @stats = stats
  end

  def view_template
    div( class: "flex flex-col") do
      h3(class: "text-center text-base font-semibold w-full text-gray-900") do
        @title
      end
      dl(class: "mt-5 grid grid-cols-1 gap-5 sm:grid-cols-2") do
        stats.each do |stat|
          div(
            class: "overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6"
          ) do
            dt(class: "truncate text-sm font-medium text-gray-500") do
              stat[:title]
            end
            dd(
              class: "mt-1 text-3xl font-semibold tracking-tight text-gray-900"
            ) { stat[:value] }
          end
        end
      end
    end
  end
end