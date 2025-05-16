class SendDataJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    context = args[:context]
    resource_class = args[:resource_class].constantize
    resources = resource_class.where id: args[:resources]
    filename = "#{resource_class.name.pluralize.downcase}-#{Date.today}.#{args[:file_type]}"

    case args[:file_type]
    when "pdf"; resource_class.pdf_file(context.html_content, filename: filename, context: self)
    when "csv"; context.send_data resource_class.to_csv(resources), filename: filename
    end
  end
end
