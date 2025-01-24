

#   create_table :task_structures do |t|
#     t.references :task, null: false, foreign_key: true
#     t.integer :assigned_to
#     t.integer :created_by
#     t.integer :reviewed_by
#     t.string :ancestry
#     t.references :project, null: false, foreign_key: true
#     t.references :location, null: false, foreign_key: true

#   end
#   add_index :task_structures, :ancestry

# t  - tasks
# td - task details
# c  - categories
# tt - tagables
# tm - task_measures
# ts - task_structures
# v  - versions
# as - active storage
#
# t	    Task ID:                  Unique identifier for the task.
# t	    Title:                    A short, descriptive name for the task.
# td    Description:              Detailed information about what the task involves.
# c	    Category/Type:            The category/type of task (e.g., feature, bug, improvement).
# t	    Priority:                 Level of importance (e.g., High, Medium, Low).
# tt    Tags:                     Keywords or labels for easy search and categorization.
# td    Creator:                  Person who created the task.
# td    Owner/Assignee:           Person responsible for completing the task.
# td    Collaborators:            Other people involved in the task.
# td    Reviewer:                 Person responsible for reviewing the task before delivery.
# tm    Goal/Objective:           High-level reason for the task.
# ts    Dependencies:             Tasks or conditions that must be completed before starting this task.
# ts    Constraints:              Restrictions or conditions affecting the task (e.g., budget, tools, deadlines).
# tm    Estimated Effort:         Time or resources estimated to complete the task (e.g., story points, hours).
# ts    Milestone:                Specific project milestone the task is part of.
# td    Created At:               Timestamp of task creation.
# td    Start Date:               Planned start date.
# td    Due Date:                 Planned deadline for completion.
# td    Completed Date:           Actual completion date.
# t	    Last Updated At:          Timestamp for the last update on the task.
# t	    Status:                   Current status (e.g., Planned, In Progress, Blocked, Completed).
# t	    Progress:                 Numeric or percentage-based progress indicator.
# v	    Activity Logs:            Chronological logs of updates, comments, and changes.
# c	    Notes:                    General notes for updates or context.
# as    Attachments:              Files, documents, or images relevant to the task.
# as    Links:                    Links to resources, documentation, or related tasks.
# tm    Actual Effort:            Time or resources spent on the task.
# tm    Outcome/Result:           Description of the final outcome (e.g., Delivered, Canceled).
# c	    Feedback:                 Notes or comments post-delivery (e.g., retrospective).
# tm    Impact:                   Measures of task success (e.g., business value delivered).
# v	    Version History:          Record of all changes to the task’s data.
# t	    Approval Status:          Whether the task has been approved (e.g., Approved, Pending).
# •	    Compliance Requirements:  Any regulatory or compliance considerations tied to the task.
# •	    Risks:                    Potential risks or issues that could affect the task.


class Task < ApplicationRecord
  include Tenantable
  include TaskStateable

  belongs_to :tasked_for, polymorphic: true
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification"
  # scope :by_user, ->(user) { where(recipient_type: "User", recipient_id: user.id) if user.present? }

  scope :by_fulltext, ->(query) { where("name LIKE :query or dewcription LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_title, ->(title) { where("title LIKE ?", "%#{title}%") if title.present? }
  scope :by_link, ->(link) { where("link LIKE ?", "%#{link}%") if link.present? }
  scope :by_description, ->(description) { where("color LIKE ?", "%#{description}%") if description.present? }
  scope :tasked_for_the, ->(tasked_for) { where("tasked_for_id = :tid and tasked_for_type = :type", tid: tasked_for.id, type: tasked_for.class.to_s) if tasked_for.present? }
  scope :uncompleted, -> { where(completed_at: nil) }
  scope :first_tasks, -> { where(priority: ..0) }

  validates :title, presence: true # , uniqueness: { scope: :tenant_id, message: I18n.t("tasks.errors.messages.title_exist") }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_title(flt["title"])
      .by_link(flt["link"])
      .by_description(flt["description"])
      .by_state(flt["state"])
  rescue
    filter.destroy if filter
    all
  end

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      "tasked_for_type",
      "tasked_for_id"
      # "title"
      # "link"
      # "description"
      # "state"
      # "priority"
      # "progress"
      # "due_at"
      # "completed_at"
      # "archived"
      # "created_at"
      # "updated_at"
      # "validation"
    ]
    f = f - [
      "due_at",
      "completed_at",
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  def name
    self.title
  end

  def completed?
    self.completed_at.present?
  end

  def self.set_order(resources, field = :title, direction = :asc)
    resources.ordered(field, direction)
  end

  def notify(action: nil, title: nil, msg: nil, rcp: nil, priority: 0)
    recipient = rcp.blank? ? self : (rcp.is_a?(User) ? rcp : User.find(rcp))

    case action
    when :tasks_remaining
      TaskNotifier.with(record: self, current_user: Current.user, title: title, message: msg, delegator: self.name).deliver(recipient)
    end
  end

  def notified?(action)
    notifications.where(action: action).any?
  end

  def self.form(resource:, editable: true)
    Tasks::Form.new resource: resource, editable: editable, fields: [ :title, :link, :description ]
  end
end
