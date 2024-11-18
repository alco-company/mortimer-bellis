class CustomersController < MortimerController
  private
    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:customer).permit(:tenant_id,
        :name,
        :external_reference,
        :is_person,
        :is_member,
        :is_debitor,
        :is_creditor,
        :street,
        :zipcode,
        :city,
        :country_key,
        :phone,
        :email,
        :webpage,
        :att_person,
        :vat_number,
        :ean_number,
        :payment_condition_type,
        :payment_condition_number_of_days,
        :member_number,
        :company_status,
        :vat_region_key,
        :invoice_mail_out_option_key,
      )
    end
end
