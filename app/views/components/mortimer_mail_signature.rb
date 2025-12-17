# frozen_string_literal: true

class MortimerMailSignature < ApplicationComponent
  attr_accessor :signature, :company, :sender

  def initialize(company: nil, sender: nil, format: :html)
    @company = company || "MORTIMER"
    @sender = sender || "The Mortimer Team"
    @format = format
  end

  def view_template
    @format == :html ? html_signature : text_only
  end

  def html_signature
    div(class: "my-8 text-sm") do
      plain I18n.t("user_mailer.regards")
      br
      strong(class: "tracking-[.25em] text-mortimer text-xl") { company.upcase }
      br
      br
      span(class: "text-sm italic text-gray-500") { sender }
    end
  end

  def text_only
    plain "\n\n#{I18n.t('user_mailer.regards')}\n#{company.upcase}\n\n#{sender}\n"
  end
end
