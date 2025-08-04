class List < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::LinkTo

  attr_reader :records, :pagy, :order_by, :group_by, :initial, :user, :batch_form

  def initialize(records:, pagy: nil, initial: false, replace: false, filter: nil, params: {}, batch_form: nil, divider: true, user: User.new, format: :html, group_by: nil, order_by: nil, &block)
    @order_by = order_by
    @group_by = group_by
    @records = records
    @order_by = order_by ? order_by.keys.first : nil
    @initial = initial
    @replace = replace
    @filter = filter.persisted? rescue false
    @pagy = pagy
    @params = params
    @user = user
    @batch_form = batch_form
    @divider = divider
    @format = format
  end

  def view_template(&block)
    case @format
    when :html  ; html_list(&block)
    when :pdf   ; pdf_list(&block)
    end
  end

  def html_list(&block)
    if initial
      # list_records
      # turbo_frame_tag "pagination", src: resources_url(format: :turbo_stream), loading: "lazy"
      # div(id: "record_list", class: "scrollbar-hide") { }
      replace_list
    else
      @replace ? replace_list : append_list
    end
  end

  def pdf_list(&block)
    rc = records&.first.class rescue nil
    div(class: "w-full") do
      div(class: "class") do
        div(class: "min-w-full") do
          table(role: "list", class: "divide-y divide-gray-100") do
            render "ListItems::#{rc}".classify.constantize.new(resource: records, params: params, user: user, format: :pdf_header)
            tbody do
              records.each do |record|
                render "ListItems::#{rc}".classify.constantize.new(resource: record, params: params, user: user, format: :pdf)
              end
            end
          end
        end
      end
    end if rc
  end

  def append_list
    turbo_stream.append "record_list" do
      list_records
      # next_pagy_page
    end
  end

  def replace_list
    flash_it
    replace_list_header
    turbo_stream.replace "record_list" do
      div(id: "record_list", class: "scrollbar-hide") { }
    end
    append_list
  end

  def list_records
    if order_by && records.any?
      fld = records.first.send(order_by)
      list_column(fld)
      # render partial: "application/date", locals: { field: fld }
      div
    end

    count = records.count
    records.each do |record|
      if record.send(order_by) != fld
        fld = (record.send(order_by))
        list_column(fld)
      end if order_by
      next_pagy_page if (count -= 1) < 2
      render "ListItems::#{resource_class}".classify.constantize.new(resource: record, params: params, user: user)
    end
  end

  def flash_it
    turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }) if flash.any?
  end

  def replace_list_header
    turbo_stream.replace("#{user.id}_list_header", partial: "application/header", locals: { batch_form: batch_form, divider: @divider })
  end

  def next_pagy_page
    if pagy.next
      turbo_frame_tag "pagination", src: resources_url(page: @pagy.next, format: :turbo_stream), loading: "lazy"
    end
  end

  def list_column(field)
    div(class: "flex justify-between gap-x-6 mb-1 px-2 py-1") do
      div(
        class: "w-full pt-10 border-b border-gray-100 text-xs font-semibold"
      ) do
        whitespace
        if field.is_a? Date or field.is_a? Time or field.is_a? DateTime
          whitespace
          plain I18n.l field, format: :day_summary
          whitespace
        else
          whitespace
          plain field
          whitespace
        end
      end
    end
  end
end
