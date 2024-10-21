class List < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  attr_reader :records

  def initialize(records, &block)
    @records = records
  end

  def view_template(&block)
    date = nil
    ul(id: "list", role: "list", class: "") do
      records.each do |record|
        if record.created_at.to_date != date
          date = record.created_at.to_date
          render partial: "date", locals: { date: date }
        end
        render record
      end
    end
  end
end
