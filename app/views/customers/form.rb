class Customers::Form < ApplicationForm
  def view_template(&)
    row field(:name).input().focus
    row field(:external_reference).input()
    row field(:is_person).boolean(class: "mort-form-bool")
    row field(:vat_number).input()
    row field(:is_debitor).boolean(class: "mort-form-bool")
    row field(:is_creditor).boolean(class: "mort-form-bool")
    row field(:hourly_rate).input()
    row field(:street).input()
    row field(:zipcode).input()
    row field(:city).input()
    row field(:country_key).select(Customer.country_keys, prompt: I18n.t(".select_country"), class: "mort-form-select")
    row field(:phone).input()
    row field(:email).input(autocomplete: false)
    row field(:webpage).input()
    row field(:att_person).input()
    row field(:ean_number).input()
    # row field(:payment_condition_type).input()
    row field(:payment_condition_type).select([ [ "Netto", "Netto" ], [ "NettoCash", "NettoCash" ], [ "CurrentMonthOut", "CurrentMonthOut" ] ], prompt: I18n.t(".select_payment_condition_type"), class: "mort-form-select")
    row field(:payment_condition_number_of_days).input()
    #
    # only used by unions
    # row field(:is_member).boolean(class: "mort-form-bool")
    # row field(:member_number).input()
    #
    row field(:company_status).input()
    row field(:vat_region_key).input()
    row field(:invoice_mail_out_option_key,).input()
    view_only field(:transmit_log).input()
  end
end
