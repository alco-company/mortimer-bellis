class EmployeeSms
  def initialize(invitation:)
    @invitation = invitation
  end

  def invite
    # send sms
    # debugger
    # I18n.t("user_mailer.invite.title")

    # I18n.t("user_mailer.invite.introduction")
    # I18n.t("user_mailer.invite.action", url: @url)
    # I18n.t("user_mailer.invite.regards")
    # @company
    # @sender
  end
end
