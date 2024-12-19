

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

# •	Task ID: Unique identifier for the task.
# •	Title: A short, descriptive name for the task.
# •	Description: Detailed information about what the task involves.
# •	Category/Type: The category/type of task (e.g., feature, bug, improvement).
# •	Priority: Level of importance (e.g., High, Medium, Low).
# •	Tags: Keywords or labels for easy search and categorization.
# •	Creator: Person who created the task.
# •	Owner/Assignee: Person responsible for completing the task.
# •	Collaborators: Other people involved in the task.
# •	Reviewer: Person responsible for reviewing the task before delivery.
# •	Goal/Objective: High-level reason for the task.
# •	Dependencies: Tasks or conditions that must be completed before starting this task.
# •	Constraints: Restrictions or conditions affecting the task (e.g., budget, tools, deadlines).
# •	Estimated Effort: Time or resources estimated to complete the task (e.g., story points, hours).
# •	Milestone: Specific project milestone the task is part of.
# •	Created At: Timestamp of task creation.
# •	Start Date: Planned start date.
# •	Due Date: Planned deadline for completion.
# •	Completed Date: Actual completion date.
# •	Last Updated At: Timestamp for the last update on the task.
# •	Status: Current status (e.g., Planned, In Progress, Blocked, Completed).
# •	Progress: Numeric or percentage-based progress indicator.
# •	Activity Logs: Chronological logs of updates, comments, and changes.
# •	Notes: General notes for updates or context.
# •	Attachments: Files, documents, or images relevant to the task.
# •	Links: Links to resources, documentation, or related tasks.
# •	Actual Effort: Time or resources spent on the task.
# •	Outcome/Result: Description of the final outcome (e.g., Delivered, Canceled).
# •	Feedback: Notes or comments post-delivery (e.g., retrospective).
# •	Impact: Measures of task success (e.g., business value delivered).
# •	Version History: Record of all changes to the task’s data.
# •	Approval Status: Whether the task has been approved (e.g., Approved, Pending).
# •	Compliance Requirements: Any regulatory or compliance considerations tied to the task.


class Task < ApplicationRecord
  include Tenantable
  include TaskStateable

  belongs_to :tasked_for, polymorphic: true

  scope :by_fulltext, ->(query) { where("name LIKE :query or dewcription LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_title, ->(title) { where("title LIKE ?", "%#{title}%") if title.present? }
  scope :by_link, ->(link) { where("link LIKE ?", "%#{link}%") if link.present? }
  scope :by_description, ->(description) { where("color LIKE ?", "%#{description}%") if description.present? }
  scope :tasked_for_the, ->(tasked_for) { where("tasked_for_id = :tid and tasked_for_type = :type", tid: tasked_for.id, type: tasked_for.class.to_s) if tasked_for.present? }
  scope :uncompleted, -> { where(completed_at: nil) }
  scope :first_tasks, -> { where(priority: ..0) }

  validates :title, presence: true, uniqueness: { scope: :tenant_id, message: I18n.t("tasks.errors.messages.title_exist") }

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

  def name
    self.title
  end

  def completed?
    self.completed_at.present?
  end

  def self.set_order(resources, field = :title, direction = :asc)
    resources.ordered(field, direction)
  end

  def self.form(resource:, editable: true)
    Tasks::Form.new resource: resource, editable: editable, fields: [ :title, :link, :description ]
  end
end
