class List < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::TurboStream

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
      turbo_frame_tag "record_list", src: resources_url(format: :turbo_stream, rewrite: true), loading: :lazy
      turbo_frame_tag("record_list_paginated", src: resources_url(page: @pagy.next, format: :turbo_stream, rewrite: true), loading: :lazy) if pagy.next
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
    end

    if pagy.next
      turbo_stream.replace "record_list_paginated" do
        turbo_frame_tag "record_list_paginated", src: resources_url(page: @pagy.next, format: :turbo_stream, rewrite: true), loading: :lazy
      end
    end
  end
end
