class EmailValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| issues(record, field) }

    end
  end

  def issues(record, field)
    if record.send(field).present? && !record.send(field).match(URI::MailTo::EMAIL_REGEXP)
      record.errors.add field, ApplicationController.helpers.tl("not a valid email address")
      return false
    end
    if record.send(field).present?
      lead = Lead.arel_table
      email_exist = Lead.where(email_address: record.send(field)).any? # .where(lead[:trial_ends_at].gt(DateTime.now).or(lead[:trial_ends_at].eq(nil)))
      email_exist ||= User.unscoped.where(user_email: record.send(field)).exists?
      if email_exist
        record.errors.add field, ApplicationController.helpers.tl("you_have_a_current_demo_account_already")
        return false
      end

    end

    true
  end
end


#
# TODO - validate email addresses against a list of disposable email domains
#

# url = URI('https://raw.githubusercontent.com/disposable/disposable-email-domains/master/domains.txt')
# response = Net::HTTP.get_response(url)

# domains = response.body.split("\n")

# domains.each do |domain|
#   REDIS_CLIENT.sadd('users:denylist:domain', domain)
# end

# class User < ApplicationRecord
#   validate :check_email_domain

#   def check_email_domain
#     domain = email.split('@').last
#     if REDIS_CLIENT.sismember('users:denylist:domain', domain)
#       errors.add(:email, 'is not allowed')
#       throw(:abort)
#     end
#   end
# end
