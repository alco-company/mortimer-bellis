# frozen_string_literal: true

class MortimerMailFooter < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  attr_accessor :punch1, :punch2

  def initialize(punch1: nil, punch2: nil)
    @punch1 = "The easiest, fastest, and most affordable Time & Attendance software in Europe."
    @punch2 = "Most likely."
  end

  def view_template
    tr do
      td(class: "text-center text-xs px-6") do
        p(class: "m-0 mb-4 uppercase tracking-[.25em] text-mortimer ") { "MORTIMER" }
        p(class: "m-0 italic text-slate-500") do
          plain punch1
          br
          plain punch2
        end
        p(class: "cursor-default") do
          # 7/10/2025
          # GMail doesn't like this in emails ATM
          #
          # render SomelinksComponent.new
        end
      end
    end
  end
end
