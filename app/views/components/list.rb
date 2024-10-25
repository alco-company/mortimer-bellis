class List < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::TurboFrameTag

  attr_reader :records

  def initialize(records:, grouped_by: :created_at, &block)
    @records = records
    @grouped_by = grouped_by
  end

  def view_template(&block)
    date = nil
    records.each do |record|
      if record.send(@grouped_by).to_date != date
        date = record.send(@grouped_by).to_date
        render partial: "date", locals: { date: date }
      end if @grouped_by
      render record
    end
  end
end
