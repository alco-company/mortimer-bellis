class Current < ActiveSupport::CurrentAttributes
  attribute :account, :user, :locale

  resets { Time.zone = nil }

  class MissingCurrentAccount < StandardError; end

  def account_or_raise!
    return Account.first if Rails.env.test?
    raise Current::MissingCurrentAccount, "You must set an account with Current.account=" unless account
    account
  end

  def user=(user)
    super
    self.account      = user.account
    self.locale       = user.locale
    Time.zone         = user.time_zone
  end
end
