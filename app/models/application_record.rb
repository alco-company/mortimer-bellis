class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include ExportCsv
  include ExportPdf

  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"

  scope :by_user, ->() { model.new.attributes.keys.include?("user_id") ? where(user_id: Current.user.id) : all }
  scope :ordered, ->(s, d) { order(s => d) }

  #
  # make it possible to handle model deletion differently from model to model
  # eg TenantRegistrationService.call(tenant, destroy: true)
  # argument step is used to control the deletion process - used on User model
  # when deleting an account
  #
  def remove(step = nil)
    destroy!
  end

  #
  # update_row is a helper method to update a row in the database
  # adding the ability to control whether the validations and callbacks are performed or not
  # only issues using this method is that the updated_at field is not updated
  # and validations are not performed, unless process is true
  #
  def update_row(attr = {}, process = false)
    begin
      attr.keys.each do |k|
        self.class.delegated?(k) ?
          self.association(self.class.delegated_to(k)).target.update_row({ k => attr[k] }, process) :
          process ?
            update(k => attr[k]) :
            update_columns(k => attr[k])
      end
    rescue => exception
      say "update_row failed due to #{exception}"
    end
  end

  # https://sunfox.org/blog/2021/03/09/arel-through-examples/
  # When writing Arel in Rails you access columns through the arel_table method on your models like so:
  # User.arel_table[:email]. However, there is a lovely little shortcut that is often added to shorten this:
  def self.[](attribute)
    arel_table[attribute]
  end

  #
  # https://discuss.rubyonrails.org/t/activerecord-add-the-like-or-and-ilike-methods/72248/7
  #
  # example:
  # users = User.where_op(:matches, email: "%@gmail.com", name: "%smith%")
  # users = users.where_op(:between, created_at: 2.days.ago..)
  # => SELECT "users".* FROM "users" WHERE "users"."email" ILIKE '@gmail.com' and "users"."name" ILIKE '%smith%' AND "users"."created_at" >= '2023-07-16 11:03:34.494592'
  #
  # This supports as operation: :between, :eq, :eq_all, :gt, :gteq, :in, :lt, :lteq, :matches and others.
  #
  def self.where_op(op, params)
    params.reduce(all) do |scope, (column, value)|
      scope.where(scope.arel_table[column].send(op, value))
    end
  end

  # implement on the model to define the exact functionality of notify
  # action is the action that triggered the notification - ie create, update, destroy
  # msg is the message to be sent
  # rcp is the recipient(s) of the message
  # priority is "how loud to notify"
  def notify(action: nil, title: nil, msg: nil, rcp: nil, priority: 0)
    #
  end

  #
  # extend this method on the model to define the associations
  # existing on the model
  # define as array of belongs_to, has_many
  # fx [ [ Customer, User, Tenant ], [ Comment, InvoiceItem ] ]
  def self.associations
    [ [], [] ]
  end

  #
  # extend this method on the model to define the field formats
  # its a callback from the superform when rendering the form
  # (in non-editable mode, the form will render the field value using this method)
  # see app/views/forms/application_form.rb#row
  #
  def field_formats(key)
    case key
    when :mugshot, :logo;                                           :file
    when :updated_at, :created_at, :punched_at, :last_punched_at;   :datetime
    when :birthday, :hired_at, :punches_settled_at;                 :date
    when :state;                                                    :enum
    when /\./;                                                      :association
    else; nil
    end
  end

  # implement this method on model that has mugshots
  # def has_mugshot?
  #   false
  # end

  # # implement this method on model that has one/more photos
  # def mugshot
  #   raise "implement this method on the model if mugshot exist!" if has_mugshot?
  # end


  def list_item(links: [])
    # TimeMaterialDetailItem.new(item: self, links: links)
    raise "implement this method on the model in order to list_item!"
  end

  # def self.form(resource:, editable: true)
  #   # Locations::Form.new resource: resource, editable: editable
  #   raise "implement this method on the model in order to show/edit post!"
  # end
  #
  # default field layout for the form
  # taken from the model attributes - possibly augmented by
  # the fields array passed to the form method
  #
  def self.form(resource:, editable: true, fields: [])
    ApplicationForm.new resource: resource, editable: editable, fields: fields
  end

  # FIXME - implement this method on models that have users
  def self.user_scope(scope)
    nil # all.by_tenant()
    # case scope
    # when "all"; all
    # when "mine"; where(user_id: Current.user.id)
    # when "my_team"; where(user_id: Current.user.team.users.pluck(:id))
    # end
  end

  # FIXME - implement this method on models that have users/teams
  def self.named_scope(scope)
    nil # all.by_tenant()
    # users = User.where name: "%#{scope}%"
    # team_users = User.where team_id: Team.where_op(:matches, name: "%#{scope}%").pluck(:id)
    # users = users + team_users if team_users.any?
    # where(user_id: users.pluck(:id))
  end

  # def self.ordered(resources, field, direction = :desc)
  #   resources.order(field => direction)
  # end

  def self.set_order(resources, field = :name, direction = :asc)
    resources.ordered(field, direction)
  end

  def select_data_attributes
    {
      lookup_target: "item",
      value: id,
      display_value: name,
      action: "keydown->lookup#optionKeydown click->lookup#selectOption"
    }
  end


  def say(msg, level = :info)
    Rails.logger.send(level, "-----------------")
    Rails.logger.send(level, msg)
    Rails.logger.send(level, "-----------------")
  end


  def self.say(msg, level = :info)
    Rails.logger.send(level, "-----------------")
    Rails.logger.send(level, msg)
    Rails.logger.send(level, "-----------------")
  end
end
