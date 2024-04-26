module Mortimer
  module Alco::Console
    def t(id)
      Current.account = Account.find(id)
      puts "Current account switched to #{Current.account.name} (#{Current.account.id})"
    end
  end
end