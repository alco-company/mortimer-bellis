class Account < ApplicationRecord
  def self.form(resource)
    Accounts::Form.new resource
  end
end
