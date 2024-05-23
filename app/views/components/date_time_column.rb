class DateTimeColumn < DateColumn
  include Phlex::Rails::Helpers::Routes

  attr_accessor :field

  def initialize(value: false, table: false, field: false, seconds: false, sort: false, css: nil, &block)
    @value = value
    @table = table
    @sort = sort        # params, like { controller: "employees", s: "name", d: "asc" }
    @seconds = seconds
    @field = field
    @class = css || "truncate"
  end

  def format_datetime(datetime)
    @seconds ?
      datetime.strftime("%d/%m/%Y %H:%M:%S") :
      datetime.strftime("%d/%m/%Y %H:%M")
  end
end
