class List < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::ButtonTo

  attr_reader :records, :pagy, :order_by, :group_by, :initial, :params, :user

  def initialize(records:, pagy:, initial: false, replace: false, params: {}, user: User.new, group_by: nil, order_by: nil, &block)
    @order_by = order_by
    @group_by = group_by
    @records = records
    @records = records.order(order_by) if order_by
    @records = records.group(group_by) if group_by
    @order_key = order_by ? order_by.keys.first : :created_at
    @initial = initial
    @replace = replace
    @pagy = pagy
    @params = params
    @user = user
  end

  def view_template(&block)
    if initial
      div(id: "record_list", class: "scrollbar-hide") { }
      turbo_frame_tag "pagination", src: resources_url(format: :turbo_stream), loading: :lazy
    else
      @replace ? replace_list : append_list

      if pagy.next
        turbo_stream.replace "pagination" do
          turbo_frame_tag "pagination", src: resources_url(page: @pagy.next, format: :turbo_stream), loading: :lazy
        end
      end
    end
  end

  def append_list
    turbo_stream.append "record_list" do
      if order_by && records.any?
        date = (records.first.send(@order_key)).to_date
        render partial: "date", locals: { date: date }
      end
      records.each do |record|
        if record.send(@order_key).to_date != date
          date = (record.send(@order_key)).to_date
          render partial: "date", locals: { date: date }
        end if order_by
        render "ListItems::#{resource_class}".classify.constantize.new resource: record, params: params, user: user
      end
    end
  end

  def replace_list
    turbo_stream.replace "record_list" do
      div(id: "record_list", class: "scrollbar-hide") { }
      turbo_frame_tag "pagination", src: resources_url(format: :turbo_stream), loading: :lazy
    end

    # turbo_stream.replace "record_list" do
    #   if order_by && records.any?
    #     date = (records.first.send(@order_key)).to_date
    #     render partial: "date", locals: { date: date }
    #   end
    #   records.each do |record|
    #     if record.send(@order_key).to_date != date
    #       date = (record.send(@order_key)).to_date
    #       render partial: "date", locals: { date: date }
    #     end if order_by
    #     render "ListItems::#{resource_class}".classify.constantize.new resource: record, params: params, user: user
    #   end
    # end
  end
end
