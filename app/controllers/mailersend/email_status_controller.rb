class Mailersend::EmailStatusController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature

  # Mailersend webhook received: #<ActionController::Parameters { "type"=>"activity.sent", "domain_id"=>"vz9dlemvn7n4kj50", "created_at"=>"2025-04-15T07:01:40.279966Z", "webhook_id"=>"v69oxl5o5rg785kw", "url"=>"https://anemone.mortimer.pro/mailersend/email_status", "data"=>{ "object"=>"activity", "id"=>"67fe041ce2197c343a7d17b9", "type"=>"sent", "created_at"=>"2025-04-15T07:00:44.000000Z", "email"=>{ "object"=>"email", "id"=>"67fe041ca5fa2c98bc12317b", "created_at"=>"2025-04-15T07:00:44.000000Z", "from"=>"info@mortimer.pro", "subject"=>"Æv altså! Du er blevet slettet fra  MORTIMER - og det er vi kede af!", "status"=>"sent", "tags"=>nil, "headers"=>nil, "message"=>{"object"=>"message", "id"=>"67fe041c3ce56f9e7676c649", "created_at"=>"2025-04-15T07:00:44.000000Z"}, "recipient"=>{"object"=>"recipient", "id"=>"67fe041cbc1edffe55ce8be0", "email"=>"walther@diechmann.net", "created_at"=>"2025-04-15T07:00:44.000000Z"}}, "morph"=>nil}, "controller"=>"mailersend/email_status", "action"=>"create", "email_status"=>{"type"=>"activity.sent", "domain_id"=>"vz9dlemvn7n4kj50", "created_at"=>"2025-04-15T07:01:40.279966Z", "webhook_id"=>"v69oxl5o5rg785kw", "url"=>"https://anemone.mortimer.pro/mailersend/email_status", "data"=>{"object"=>"activity", "id"=>"67fe041ce2197c343a7d17b9", "type"=>"sent", "created_at"=>"2025-04-15T07:00:44.000000Z", "email"=>{"object"=>"email", "id"=>"67fe041ca5fa2c98bc12317b", "created_at"=>"2025-04-15T07:00:44.000000Z", "from"=>"info@mortimer.pro", "subject"=>"Æv altså! Du er blevet slettet fra  MORTIMER - og det er vi kede af!", "status"=>"sent", "tags"=>nil, "headers"=>nil, "message"=>{"object"=>"message", "id"=>"67fe041c3ce56f9e7676c649", "created_at"=>"2025-04-15T07:00:44.000000Z"}, "recipient"=>{"object"=>"recipient", "id"=>"67fe041cbc1edffe55ce8be0", "email"=>"walther@diechmann.net", "created_at"=>"2025-04-15T07:00:44.000000Z"}}, "morph"=>nil}}} permitted: false>
  # Mailersend webhook received: #<ActionController::Parameters {"type"=>"activity.delivered", "domain_id"=>"vz9dlemvn7n4kj50", "created_at"=>"2025-04-15T07:02:54.563798Z", "webhook_id"=>"v69oxl5o5rg785kw", "url"=>"https://anemone.mortimer.pro/mailersend/email_status", "data"=>{"object"=>"activity", "id"=>"67fe046e90e6562efa73fa67", "type"=>"delivered", "created_at"=>"2025-04-15T07:01:25.000000Z", "email"=>{"object"=>"email", "id"=>"67fe043d42a1aee9f1ef3c93", "created_at"=>"2025-04-15T07:01:17.000000Z", "from"=>"info@mortimer.pro", "subject"=>"Invitation til at oprette en brugerprofil på  MORTIMER", "status"=>"delivered", "tags"=>nil, "headers"=>nil, "message"=>{"object"=>"message", "id"=>"67fe043d0895192680f2669a", "created_at"=>"2025-04-15T07:01:17.000000Z"}, "recipient"=>{"object"=>"recipient", "id"=>"67fe041cbc1edffe55ce8be0", "email"=>"walther@diechmann.net", "created_at"=>"2025-04-15T07:00:44.000000Z"}}, "morph"=>nil}, "controller"=>"mailersend/email_status", "action"=>"create", "email_status"=>{"type"=>"activity.delivered", "domain_id"=>"vz9dlemvn7n4kj50", "created_at"=>"2025-04-15T07:02:54.563798Z", "webhook_id"=>"v69oxl5o5rg785kw", "url"=>"https://anemone.mortimer.pro/mailersend/email_status", "data"=>{"object"=>"activity", "id"=>"67fe046e90e6562efa73fa67", "type"=>"delivered", "created_at"=>"2025-04-15T07:01:25.000000Z", "email"=>{"object"=>"email", "id"=>"67fe043d42a1aee9f1ef3c93", "created_at"=>"2025-04-15T07:01:17.000000Z", "from"=>"info@mortimer.pro", "subject"=>"Invitation til at oprette en brugerprofil på  MORTIMER", "status"=>"delivered", "tags"=>nil, "headers"=>nil, "message"=>{"object"=>"message", "id"=>"67fe043d0895192680f2669a", "created_at"=>"2025-04-15T07:01:17.000000Z"}, "recipient"=>{"object"=>"recipient", "id"=>"67fe041cbc1edffe55ce8be0", "email"=>"walther@diechmann.net", "created_at"=>"2025-04-15T07:00:44.000000Z"}}, "morph"=>nil}}} permitted: false>
  # Mailersend webhook received: #<ActionController::Parameters {"type"=>"activity.opened_unique", "domain_id"=>"vz9dlemvn7n4kj50", "created_at"=>"2025-04-15T07:04:32.402984Z", "webhook_id"=>"v69oxl5o5rg785kw", "url"=>"https://anemone.mortimer.pro/mailersend/email_status", "data"=>{"object"=>"activity", "id"=>"67fe04fdbe63666752f2ef97", "type"=>"opened", "created_at"=>"2025-04-15T07:04:29.000000Z", "email"=>{"object"=>"email", "id"=>"67fe043d42a1aee9f1ef3c93", "created_at"=>"2025-04-15T07:01:17.000000Z", "from"=>"info@mortimer.pro", "subject"=>"Invitation til at oprette en brugerprofil på  MORTIMER", "status"=>"delivered", "tags"=>nil, "headers"=>nil, "message"=>{"object"=>"message", "id"=>"67fe043d0895192680f2669a", "created_at"=>"2025-04-15T07:01:17.000000Z"}, "recipient"=>{"object"=>"recipient", "id"=>"67fe041cbc1edffe55ce8be0", "email"=>"walther@diechmann.net", "created_at"=>"2025-04-15T07:00:44.000000Z"}}, "morph"=>{"object"=>"open", "id"=>"67fe04fd77ab2142afaa420f", "created_at"=>"2025-04-15T07:04:29.000000Z", "ip"=>"2a09:bac3:2ff3:28c::41:100"}}, "controller"=>"mailersend/email_status", "action"=>"create", "email_status"=>{"type"=>"activity.opened_unique", "domain_id"=>"vz9dlemvn7n4kj50", "created_at"=>"2025-04-15T07:04:32.402984Z", "webhook_id"=>"v69oxl5o5rg785kw", "url"=>"https://anemone.mortimer.pro/mailersend/email_status", "data"=>{"object"=>"activity", "id"=>"67fe04fdbe63666752f2ef97", "type"=>"opened", "created_at"=>"2025-04-15T07:04:29.000000Z", "email"=>{"object"=>"email", "id"=>"67fe043d42a1aee9f1ef3c93", "created_at"=>"2025-04-15T07:01:17.000000Z", "from"=>"info@mortimer.pro", "subject"=>"Invitation til at oprette en brugerprofil på  MORTIMER", "status"=>"delivered", "tags"=>nil, "headers"=>nil, "message"=>{"object"=>"message", "id"=>"67fe043d0895192680f2669a", "created_at"=>"2025-04-15T07:01:17.000000Z"}, "recipient"=>{"object"=>"recipient", "id"=>"67fe041cbc1edffe55ce8be0", "email"=>"walther@diechmann.net", "created_at"=>"2025-04-15T07:00:44.000000Z"}}, "morph"=>{"object"=>"open", "id"=>"67fe04fd77ab2142afaa420f", "created_at"=>"2025-04-15T07:04:29.000000Z", "ip"=>"2a09:bac3:2ff3:28c::41:100"}}}} permitted: false>
  # Mailersend webhook received: #<ActionController::Parameters {"type"=>"activity.clicked_unique", "domain_id"=>"vz9dlemvn7n4kj50", "created_at"=>"2025-04-15T07:11:22.866909Z", "webhook_id"=>"v69oxl5o5rg785kw", "url"=>"https://anemone.mortimer.pro/mailersend/email_status", "data"=>{"object"=>"activity", "id"=>"67fe06835a3a7659386f1373", "type"=>"clicked", "created_at"=>"2025-04-15T07:10:59.000000Z", "email"=>{"object"=>"email", "id"=>"67fe043d42a1aee9f1ef3c93", "created_at"=>"2025-04-15T07:01:17.000000Z", "from"=>"info@mortimer.pro", "subject"=>"Invitation til at oprette en brugerprofil på  MORTIMER", "status"=>"delivered", "tags"=>nil, "headers"=>nil, "message"=>{"object"=>"message", "id"=>"67fe043d0895192680f2669a", "created_at"=>"2025-04-15T07:01:17.000000Z"}, "recipient"=>{"object"=>"recipient", "id"=>"67fe041cbc1edffe55ce8be0", "email"=>"walther@diechmann.net", "created_at"=>"2025-04-15T07:00:44.000000Z"}}, "morph"=>{"object"=>"click", "id"=>"67fe0683c2f6114bb10f7b0c", "created_at"=>"2025-04-15T07:10:59.000000Z", "ip"=>"188.228.2.218", "url"=>"https://anemone.mortimer.pro/users/invitations/accept?token=rtxRinyB7NgTTLninLQhcHLY"}}, "controller"=>"mailersend/email_status", "action"=>"create", "email_status"=>{"type"=>"activity.clicked_unique", "domain_id"=>"vz9dlemvn7n4kj50", "created_at"=>"2025-04-15T07:11:22.866909Z", "webhook_id"=>"v69oxl5o5rg785kw", "url"=>"https://anemone.mortimer.pro/mailersend/email_status", "data"=>{"object"=>"activity", "id"=>"67fe06835a3a7659386f1373", "type"=>"clicked", "created_at"=>"2025-04-15T07:10:59.000000Z", "email"=>{"object"=>"email", "id"=>"67fe043d42a1aee9f1ef3c93", "created_at"=>"2025-04-15T07:01:17.000000Z", "from"=>"info@mortimer.pro", "subject"=>"Invitation til at oprette en brugerprofil på  MORTIMER", "status"=>"delivered", "tags"=>nil, "headers"=>nil, "message"=>{"object"=>"message", "id"=>"67fe043d0895192680f2669a", "created_at"=>"2025-04-15T07:01:17.000000Z"}, "recipient"=>{"object"=>"recipient", "id"=>"67fe041cbc1edffe55ce8be0", "email"=>"walther@diechmann.net", "created_at"=>"2025-04-15T07:00:44.000000Z"}}, "morph"=>{"object"=>"click", "id"=>"67fe0683c2f6114bb10f7b0c", "created_at"=>"2025-04-15T07:10:59.000000Z", "ip"=>"188.228.2.218", "url"=>"https://anemone.mortimer.pro/users/invitations/accept?token=rtxRinyB7NgTTLninLQhcHLY"}}}} permitted: false>

  # Mailersend webhook received:
  # <ActionController::Parameters {
  #   "type"=>"activity.spam_complaint",
  #   "domain_id"=>"vz9dlemvn7n4kj50",
  #   "created_at"=>"2025-04-14T19:07:42.257160Z",
  #   "webhook_id"=>"v69oxl5o5rg785kw",
  #   "url"=>"https://anemone.mortimer.pro/mailersend/email_status",
  #   "data"=>{
  #     "object"=>"activity",
  #     "id"=>"62f114f8165fe0d8db0288e5",
  #     "type"=>"spam_complaint",
  #     "created_at"=>"2022-08-08T13:51:52.747000Z",
  #     "email"=>{
  #       "object"=>"email",
  #       "id"=>"62f114f7165fe0d8db0288e2",
  #       "created_at"=>"2025-04-14T19:06:42.257277Z",
  #       "from"=>"test@mortimer.pro",
  #       "subject"=>"Test subject",
  #       "status"=>"delivered",
  #       "tags"=>nil,
  #       "headers"=>nil,
  #       "message"=>{
  #         "object"=>"message",
  #         "id"=>"62fb66bef54a112e920b5493",
  #         "created_at"=>"2025-04-14T19:05:42.257227Z"
  #         },
  #       "recipient"=>{
  #         "object"=>"recipient",
  #         "id"=>"62c69be104270ee9c0074d32",
  #         "email"=>"test@example.com",
  #         "created_at"=>"2025-04-14T19:00:42.257227Z"
  #       }
  #     },
  #     "morph"=>{
  #       "object"=>"spam_complaint",
  #       "reason"=>nil
  #     },
  #     "template_id"=>"0z76k5jg0o3yeg2d"
  #   },
  #   "controller"=>"mailersend/email_status",
  #   "action"=>"create",
  #   "email_status"=>{
  #     "type"=>"activity.spam_complaint",
  #     "domain_id"=>"vz9dlemvn7n4kj50",
  #     "created_at"=>"2025-04-14T19:07:42.257160Z",
  #     "webhook_id"=>"v69oxl5o5rg785kw",
  #     "url"=>"https://anemone.mortimer.pro/mailersend/email_status",
  #     "data"=>{
  #       "object"=>"activity",
  #       "id"=>"62f114f8165fe0d8db0288e5",
  #       "type"=>"spam_complaint",
  #       "created_at"=>"2022-08-08T13:51:52.747000Z",
  #       "email"=>{
  #         "object"=>"email",
  #         "id"=>"62f114f7165fe0d8db0288e2",
  #         "created_at"=>"2025-04-14T19:06:42.257277Z",
  #         "from"=>"test@mortimer.pro",
  #         "subject"=>"Test subject",
  #         "status"=>"delivered",
  #         "tags"=>nil,
  #         "headers"=>nil,
  #         "message"=>{
  #           "object"=>"message",
  #           "id"=>"62fb66bef54a112e920b5493",
  #           "created_at"=>"2025-04-14T19:05:42.257227Z"
  #         },
  #         "recipient"=>{
  #           "object"=>"recipient",
  #           "id"=>"62c69be104270ee9c0074d32",
  #           "email"=>"test@example.com",
  #           "created_at"=>"2025-04-14T19:00:42.257227Z"
  #         }
  #       },
  #       "morph"=> {
  #         "object"=>"spam_complaint",
  #         "reason"=>nil
  #       },
  #       "template_id"=>"0z76k5jg0o3yeg2d"
  #     }
  #   }
  # } permitted: false>

  def create
    # Process the webhook payload by notifying sender that email was
    # not processed correctly
    #
    case params[:type]
    # happy paths
    when "activity.sent";                 no_op
    when "activity.delivered";            no_op
    when "activity.opened_unique";        no_op
    when "activity.clicked_unique";       no_op
    # happy - but either an issue with the invite or user in doubt
    when "activity.clicked";              no_op
    when "activity.opened";               no_op
    # unhappy paths
    when "activity.soft_bounced";         no_op
    when "activity.hard_bounced";         no_op
    when "activity.spam_complaint";       no_op

    # not used
    # when "activity.unsubscribed";         no_op
    # when "activity.survey_opened";        no_op
    # when "activity.survey_submitted";     no_op
    # when "sender_identity.verified";      no_op
    # when "maintenance.start";             no_op
    # when "maintenance.end";               no_op
    # when "inbound_forward.failed";        no_op
    # when "email_single.verified";         no_op
    # when "email_list.verified";           no_op
    else no_op
    end
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

  def no_op
    true
  end
end
