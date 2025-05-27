module ActionMailer
  module DeliveryMethods
    class Mailersend
      attr_accessor :settings

      def initialize(settings)
        @settings = settings
      end

      def deliver!(mail)
        # Convert ActionMailer::Mail object to Mailersend format
        payload = {
          "from" => {
            "email" => mail.from.first,
            "name" => mail.header["from"].display_names.first
          },
          "to" => mail.to.map { |email| { "email" => email } },
          "subject" => mail.subject,
          "html" => mail.html_part&.body&.raw_source || mail.body.raw_source
        }

        # Add text version if present
        if mail.text_part
          payload["text"] = mail.text_part.body.raw_source
        end

        # Add CC recipients if present
        if mail.cc.present?
          payload["cc"] = mail.cc.map { |email| { "email" => email } }
        end

        # Add BCC recipients if present
        if mail.bcc.present?
          payload["bcc"] = mail.bcc.map { |email| { "email" => email } }
        end

        # Add attachments if present
        if mail.attachments.any?
          payload["attachments"] = mail.attachments.map do |attachment|
            {
              "filename" => attachment.filename,
              "content" => Base64.encode64(attachment.body.raw_source),
              "content_type" => attachment.content_type
            }
          end
        end

        # Send via Mailersend API
        response = HTTParty.post(
          "https://api.mailersend.com/v1/email",
          body: payload.to_json,
          headers: {
            "Authorization" => "Bearer #{settings[:api_key]}",
            "Content-Type" => "application/json",
            "X-Requested-With" => "XMLHttpRequest"
          }
        )

        unless response.success?
          raise "Mailersend API error: #{response.body}"
        end

        response
      end
    end
  end
end
