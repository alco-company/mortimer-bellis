# frozen_string_literal: true

# module ExportPdf
module ExportPdf
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def pdf_file(html)
      html_filename = Rails.root.join("tmp", "#{Current.user.id}_pdf_input.html")
      pdf_filename = Rails.root.join("tmp", "#{Current.user.id}_output.pdf")
      File.open(html_filename, "wb") { |f| f.write(html) }
      unless BuildPdfJob.new.perform(html: html_filename, pdf: pdf_filename)
        pdf_filename = nil
      end
      File.delete(html_filename)
      pdf_filename
    end

    def pdf_stream(html)
      pdf_file = pdf_file(html)
      pdf_file ? File.read(pdf_file) : nil
    end
  end
end
