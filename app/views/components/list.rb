class List < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::Flash

  attr_reader :records, :pagy, :order_by, :group_by, :initial, :params, :user, :batch_form

  def initialize(records:, pagy:, initial: false, replace: false, filter: nil, params: {}, batch_form: nil, user: User.new, group_by: nil, order_by: nil, &block)
    @order_by = order_by
    @group_by = group_by
    @records = records
    @records = records.order(order_by) if order_by
    @records = records.group(group_by) if group_by
    @order_key = order_by ? order_by.keys.first : :created_at
    @initial = initial
    @replace = replace
    @filter = filter.persisted? rescue false
    @pagy = pagy
    @params = params
    @user = user
    @batch_form = batch_form
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
    flash_it
    replace_list_header
    turbo_stream.replace "record_list" do
      div(id: "record_list", class: "scrollbar-hide") { }
      turbo_frame_tag "pagination", src: resources_url(format: :turbo_stream), loading: :lazy
    end
  end

  def flash_it
    turbo_stream.replace("flash_container", partial: "application/flash_message") if flash.any?
  end

  def replace_list_header
    turbo_stream.replace("#{user.id}_list_header", partial: "application/header", locals: { batch_form: batch_form })

    # turbo_frame_tag "#{user.id}_list_header" do
    #   button_to helpers.filter_url(@filter, url: resources_url), method: :delete, class: "group relative ml-2 h-3.5 w-3.5 rounded-sm hover:bg-gray-500/20", data: { turbo_stream: true } do
    #     span(
    #       class:
    #         %(#{"hidden" if !@filter } inline-flex items-center rounded-md bg-gray-50 px-1.5 py-0.5 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10)
    #     ) do
    #       plain I18n.t("filters.filtered")
    #       span(class: "sr-only") { "Remove" }
    #       svg(
    #         viewbox: "0 0 14 14",
    #         class: "h-3.5 w-3.5 stroke-gray-700/50 group-hover:stroke-gray-700/75"
    #       ) { |s| s.path(d: "M4 4l6 6m0-6l-6 6") }
    #       span(class: "absolute -inset-1")
    #     end
    #   end
    # end
  end
end
