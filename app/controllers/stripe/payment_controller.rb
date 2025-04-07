#
# <Stripe::Checkout::Session:0x17444 id=cs_test_a1VjTFk7Bp9q2qzvAs3pEQi1HKT3ZtrhkboQSGSbHisppmHaKScVw3xGsH> JSON: {
#   "id": "cs_test_a1VjTFk7Bp9q2qzvAs3pEQi1HKT3ZtrhkboQSGSbHisppmHaKScVw3xGsH",
#   "object": "checkout.session",
#   "adaptive_pricing": null,
#   "after_expiration": null,
#   "allow_promotion_codes": false,
#   "amount_subtotal": 300,
#   "amount_total": 300,
#   "automatic_tax": {"enabled":false,"liability":null,"status":null},
#   "billing_address_collection": "auto",
#   "cancel_url": "https://stripe.com",
#   "client_reference_id": null,
#   "client_secret": null,
#   "collected_information": {"shipping_details":null},
#   "consent": null,
#   "consent_collection": null,
#   "created": 1743790470,
#   "currency": "eur",
#   "currency_conversion": null,
#   "custom_fields": [],
#   "custom_text": {"after_submit":null,"shipping_address":null,"submit":null,"terms_of_service_acceptance":null},
#   "customer": "cus_S4NWV84rxd4Fyb",
#   "customer_creation": "if_required",
#   "customer_details": {"address":{"city":null,"country":"DK","line1":null,"line2":null,"postal_code":null,"state":null},"email":"walther@alco.dk","name":"Walther Diechmann","phone":null,"tax_exempt":"none","tax_ids":[]},
#   "customer_email": null,
#   "discounts": [],
#   "expires_at": 1743876870,
#   "invoice": "in_1RAElgRm1WLbJgV0Pw8589r8",
#   "invoice_creation": null,
#   "livemode": false,
#   "locale": "auto",
#   "metadata": {},
#   "mode": "subscription",
#   "payment_intent": null,
#   "payment_link": "plink_1RAEZIRm1WLbJgV0Uhr6CWes",
#   "payment_method_collection": "always",
#   "payment_method_configuration_details": {"id":"pmc_1R93rjRm1WLbJgV0nvwYvKiX","parent":null},
#   "payment_method_options": {"card":{"request_three_d_secure":"automatic"}},
#   "payment_method_types": [
#     "card",
#     "link"
#   ],
#   "payment_status": "paid",
#   "permissions": null,
#   "phone_number_collection": {"enabled":false},
#   "recovered_from": null,
#   "saved_payment_method_options": {"allow_redisplay_filters":["always"],"payment_method_remove":null,"payment_method_save":null},
#   "setup_intent": null,
#   "shipping_address_collection": null,
#   "shipping_cost": null,
#   "shipping_options": [],
#   "status": "complete",
#   "submit_type": "auto",
#   "subscription": "sub_1RAElgRm1WLbJgV0iGj2VYPQ",
#   "success_url": "https://localhost:3000/stripe/payment?ci={CHECKOUT_SESSION_ID}",
#   "total_details": {"amount_discount":0,"amount_shipping":0,"amount_tax":0},
#   "ui_mode": "hosted",
#   "url": null,
#   "wallet_options": null
# }
#
#

class Stripe::PaymentController < ApplicationController
  # Stripe callback from completed payment
  # GET "/stripe/payment?ui=232&ci=cs_test_a1M01tZueaLHFtvXQVUbzwpvDZLq5QHNxVJ2WcsikjuBRM8SWCwn5tgV61"
  #
  # param ui = user_id
  # param ci = checkout_session_id
  #
  def new
    Current.system_user = User.find(params["ui"])
    ss = Stripe::Service.new user: Current.get_user
    if ss.confirm_payment(params["ci"])
      redirect_to edit_tenant_url(Current.get_tenant), success: t("tenants.modal.buy_product.payment_successfully_confirmed")
    else
      redirect_to edit_tenant_url(Current.get_tenant), warning: t("tenants.modal.buy_product.payment_not_confirmed")
    end
  end
end
