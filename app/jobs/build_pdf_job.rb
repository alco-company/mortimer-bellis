class BuildPdfJob < ApplicationJob
  queue_as :default

  #
  # html:
  # css:
  # attachments: []
  def perform(*args)
    url = "http://localhost:8080"
    options = {
      headers: {
        "ContentType" => "multipart/form-data"
      },
      body: {
        html: File.open( "test.html")
      }
    }
    response = HTTParty.post(url, options)
    File.open("test.pdf", "wb") do |f|
      f.write response.parsed_response
    end
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
