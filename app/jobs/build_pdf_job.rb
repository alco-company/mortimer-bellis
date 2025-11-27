class BuildPdfJob < ApplicationJob
  queue_as :default

  #
  # html:
  # css:
  # attachments: []
  # pdf:
  #
  def perform(**args)
    super(**args)
    url = "http://#{ENV["PDF_HOST"]}:8080"
    html = args.fetch(:html)
    raise "No HTML file provided" unless html && File.exist?(html)
    pdf = args.fetch(:pdf)
    raise "No PDF output file provided" unless pdf

    options = {
      headers: {
        "ContentType" => "multipart/form-data"
      },
      body: {
        html: File.open(html, "rb")
      }
    }
    response = HTTParty.post(url, options)
    File.open(pdf, "wb") do |f|
      f.write response.parsed_response
    end
    true
  rescue StandardError => e
    UserMailer.error_report(e.to_s, "BuildPdfJob#perform").deliver_later
    false
  end
end


#     if (
#         part.name in ['html', 'css']
#         or part.name.startswith('attachment.')
#         or part.name.startswith('asset.')
#     ):
#         form_data[part.name] = await save_part_to_file(part, temp_dir)

# if 'html' not in form_data:
#     logger.info('Bad request. No html file provided.')
#     return web.Response(status=400, text="No html file provided.")

# html = HTML(filename=form_data['html'], url_fetcher=URLFetcher(form_data.values()))
# if 'css' in form_data:
#     css = CSS(filename=form_data['css'], url_fetcher=URLFetcher(form_data.values()))
# else:
#     css = CSS(string='@page { size: A4; margin: 2cm 2.5cm; }')

# attachments = [
#     attachment for name, attachment in form_data.items()
#     if name.startswith('attachment.')
# ]
# pdf_filename = os.path.join(temp_dir, 'output.pdf')
