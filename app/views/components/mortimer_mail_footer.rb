# frozen_string_literal: true

class MortimerMailFooter < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  attr_accessor :signature, :company, :sender

  def initialize(signature: false, company: nil, sender: nil)
    @signature = signature
    @company = company || "MORTIMER"
    @sender = sender || "The Mortimer Team"
  end

  def view_template
    signature ? mail_signature : email_footer
  end

  def mail_signature
    div(class: "my-8 text-sm") do
      plain I18n.t("user_mailer.welcome.regards")
      br
      strong(class: "tracking-[.25em] text-mortimer text-xl") { company.upcase }
      br
      br
      span(class: "text-sm italic text-gray-500") { sender }
    end
  end

  def email_footer
    p(class: "m-0 mb-4 uppercase tracking-[.25em] text-mortimer ") { "MORTIMER" }
    p(class: "m-0 italic text-slate-500") do
      plain "The easiest, fastest, and most affordable Time & Attendance software in Europe."
      br
      plain "Most likely."
    end
    p(class: "cursor-default") do
      render SomelinksComponent.new
    end
  end
end
