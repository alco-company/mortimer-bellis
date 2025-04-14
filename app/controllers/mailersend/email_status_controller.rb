class Mailersend::EmailStatusController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature

  def create
    # Process the webhook payload
    Rails.logger.info("Mailersend webhook received: #{params.inspect}")
    head :ok
  end

  private

  def verify_webhook_signature
    signature = request.headers["Signature"]
    timestamp = request.headers["Date"]
    payload = request.raw_post

    # Reconstruct the signature string
    string_to_sign = "#{timestamp}#{payload}"

    # Generate HMAC signature using SHA256
    hmac = OpenSSL::HMAC.hexdigest(
      "SHA256",
      ENV["MAILERSEND_API_WEBHOOK_SECRET"],
      string_to_sign
    )

    # Compare signatures using secure comparison
    unless ActiveSupport::SecurityUtils.secure_compare(hmac, signature)
      head :unauthorized
      false
    end
  end
end
