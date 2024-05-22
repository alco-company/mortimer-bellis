class NumberColumn < Column
  def initialize(value: false, table: false, field: false, sort: false, css: nil, &block)
    @value = value
    @table = table
    @sort = sort        # params, like { controller: "employees", s: "name", d: "asc" }
    @field = field
    @class = css || "text-right"
  end
end
