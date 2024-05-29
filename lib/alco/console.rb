require "irb/command"
class AccountSetter < IRB::Command::Base
  category "AccountSetter"
  description "Set the current account"
  help_message <<~HELP
    sets the current account

    usage: t <account id>
  HELP

  def execute(id)
    Current.account = Account.find(id)
    puts "Current account switched to #{Current.account.name} (#{Current.account.id})"
  end
end

#
# use this to find records with /:id
# ex Account/7
# thx to https://twitter.com/aviflombaum/status/1785424025105133806
#
# class ::ApplicationRecord
#   class << self
#     alias_method :/, :find
#   end
# end
if Rails.env.local?
  IRB::Command.register :t, AccountSetter
end
