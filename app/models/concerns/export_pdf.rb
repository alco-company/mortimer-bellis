# frozen_string_literal: true

# module ExportPdf
module ExportPdf
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def to_pdf(html)
      html_filename = Rails.root.join("tmp", "#{Current.user.id}_pdf_input.html")
      pdf_filename = Rails.root.join("tmp", "#{Current.user.id}_output.pdf")
      File.open(html_filename, "wb") { |f| f.write(html) }
      if BuildPdfJob.new.perform(html: html_filename, pdf: pdf_filename)
        # File.delete(html_filename)
        File.read pdf_filename
      else
        File.delete(html_filename)
        nil
      end
    end
  end
end
