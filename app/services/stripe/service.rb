class Stripe::Service < SaasService
  attr_accessor :settings, :provided_service

  def initialize(provided_service: nil, settings: nil, user: Current.get_user)
    Current.system_user = user
    @provided_service = provided_service || Current.get_tenant.provided_services.by_name("Stripe").first || ProvidedService.new
    @settings = settings || @provided_service&.service_params_hash || empty_params
    @settings = empty_params if @settings["api_key"].blank?
  end

  def empty_params
    { "api_key"=> ENV["STRIPE_SECRET_KEY"] }
  end

  #
  # product: essential | pro
  # url: "https://localhost:3000/stripe/payment?ui=Current.user.id&ci={CHECKOUT_SESSION_ID}"
  # price: mth | yr
  #
  def payment_link(product: nil, price: nil, url: nil)
    return false if product.nil? || price.nil? || url.nil?
    Stripe.api_key = settings["api_key"]
    url += "&ci={CHECKOUT_SESSION_ID}"

    prices = Stripe::Price.list({ limit: 3 })
    price = prices.select { |p| p.lookup_key =~ /#{product}_#{price}/ }.first
    pl = Stripe::PaymentLink.create({
      line_items: [
        {
          price: price.id,
          quantity: 1
        }
      ],
      after_completion: {
        type: "redirect",
        redirect: {
          url: url
        }
      }
    })
    return pl.url if pl.active
    false
  end

  def confirm_payment(checkout_session_id)
    Stripe.api_key = settings["api_key"]
    scs = Stripe::Checkout::Session.retrieve checkout_session_id
    if scs["payment_status"] == "paid"
      invoice = Stripe::Invoice.retrieve scs["invoice"]
      prod = Stripe::Product.retrieve(invoice.lines.data.first.pricing.price_details.product)
      if prod.present?
        case prod.name
        when /pro/; Current.get_tenant.update license: 3
        when /essential/; Current.get_tenant.update license: 2
        end
      end

      TenantMailer.with(tenant: Current.get_tenant, user: Current.get_user, recipient: Current.get_tenant.email, invoice_pdf: invoice.invoice_pdf).send_invoice.deliver_later
      Current.get_tenant.update license_changed_at: Time.current,
        license_expires_at: Time.at(invoice.lines.data.first.period.end).utc
      true
    else
      false
    end
  end
end
