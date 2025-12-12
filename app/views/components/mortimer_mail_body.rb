# frozen_string_literal: true

class MortimerMailBody < ApplicationComponent
  def view_template
    tr do
      td(class: "p-12 sm:px-6 text-base text-slate-700 bg-white rounded-sm shadow-xs") do
        yield
      end
    end
  end
end
