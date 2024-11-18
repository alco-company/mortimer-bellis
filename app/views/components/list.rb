class List < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::ButtonTo

  attr_reader :records, :pagy, :grouped_by, :initial, :params, :user

  def initialize(records:, pagy:, initial: false, params: {}, user: User.new, grouped_by: nil, &block)
    @records = records
    @grouped_by = grouped_by
    @initial = initial
    @pagy = pagy
    @params = params
    @user = user
  end

  def view_template(&block)
    if initial
      div(id: "record_list") { }
      turbo_frame_tag "pagination", src: resources_url(format: :turbo_stream), loading: :lazy
    else
      turbo_stream.append "record_list" do
        if grouped_by
          date = records.first.send(grouped_by).to_date
          render partial: "date", locals: { date: date }
        end
        records.each do |record|
          if record.send(grouped_by).to_date != date
            date = record.send(grouped_by).to_date
            render partial: "date", locals: { date: date }
          end if grouped_by
          render "ListItems::#{resource_class}".classify.constantize.new resource: record, params: params, user: user
        end
      end

      if pagy.next
        turbo_stream.replace "pagination" do
          turbo_frame_tag "pagination", src: resources_url(page: @pagy.next, format: :turbo_stream), loading: :lazy
        end
      end
    end
  end
end
