# frozen_string_literal: true

# module ExportCSV
module ExportCsv
  extend ActiveSupport::Concern

  included do
    #
    # csv_headers and csv_row are used by ExportCsv
    # describing the csv file to be generated
    #
    # both methods may be implemented on the model
    #
    # def csv_header header=nil
    #   #%i[id name]
    #   return header unless header.nil?
    #   attributes.keys.collect &:to_sym
    # end

    #
    # csv_row builds an array of values for the csv file row
    # this is used by ExportCsv
    # def csv_row fields=nil
    #   # [id, name]
    #   return fields unless fields.nil?
    #   attributes.values
    # end
  end

  class_methods do
    def csv_header(header = nil)
      return header unless new.respond_to? :csv_header
      new.csv_header header
    rescue => exception
      [ :id, :error_getting_csv_header ]
    end

    def to_csv(resources, header = nil)
      require "csv"
      options = { col_sep: ";", encoding: "utf-8" }
      headers = (csv_header header) || column_names

      CSV.generate(headers: true, **options) do |csv|
        csv << headers

        resources.each do |r|
          csv << r.attributes.values_at(*headers) unless r.respond_to? :csv_row
        end
      end
    end
  end
end
