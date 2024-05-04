module Mortimer
  module Alco::SqlStatements
    #
    # @records = ActiveRecord::Base.connection.exec_query(sql)
    # # Get the column names of the result:
    # @records.columns
    # # => ["id", "zip_code", "county"]
    #
    # # Get the record values of the result:
    # @records.rows
    # # => [[1, "94121", "San Francisco"],
    #       [2, "94110", "San Francisco"],
    #       ...
    #      ]
    #
    # # Get an array of hashes representing the result (column => value):
    # @records.to_hash
    # # => [{"id" => 1, "zip_code" => "94121", "county" => "San Francisco"},
    #       {"id" => 2, "zip_code" => "94110", "county" => "San Francisco"},
    #       ...
    #      ]
    #
    # # ActiveRecord::Result also includes Enumerable.
    # @records.each do |row|
    #   puts row['zip_code'] + " " + row['county']
    # end
    #
    # returns an array of hashes representing the result (column => value)
    # or an ActiveRecord::Result object
    #
    def execute_statement(sql, return_hash = false)
      records = ActiveRecord::Base.connection.exec_query(sql)
      if return_hash
        records.entries
      else
        records
      end
    end
  end
end
