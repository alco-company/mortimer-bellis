module Mortimer
  module Alco::Console
    def t(id)
      Current.account = Account.find(id)
      puts "Current account switched to #{Current.account.name} (#{Current.account.id})"
    end

    #
    # use this to find records with /:id
    # ex Account/7
    # thx to https://twitter.com/aviflombaum/status/1785424025105133806
    #
    class ::ApplicationRecord
      class << self
        alias_method :/, :find
      end
    end
  end
end
