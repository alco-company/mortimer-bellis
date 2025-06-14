# frozen_string_literal: true

# module ExportPdf
module ExportPdf
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def pdf_file(html, filename: nil, context: nil)
      html_filename = Rails.root.join("tmp", "#{Current.user.id}_pdf_input.html")
      pdf_filename = Rails.root.join("tmp", "#{Current.user.id}_output.pdf")
      File.open(html_filename, "wb") { |f| f.write(html) }
      unless BuildPdfJob.perform_later(tenant: Current.tenant, user: Current.user, html: html_filename.to_s, pdf: pdf_filename.to_s, filename: filename.to_s)
        pdf_filename= nil
      else
        context.send_file pdf_filename.to_s, type: "application/pdf", filename: filename.to_s
      end
      # File.delete(html_filename) if File.exist?(html_filename)
      # File.delete(pdf_filename) if File.exist?(pdf_filename)
    end

    def pdf_stream(html)
      pdf_file = pdf_file(html)
      pdf_file ? File.read(pdf_file.to_s) : nil
    end
  end
end
