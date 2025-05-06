class CustomersController < MortimerController
  private

    def resource_create
      if resource_params[:hourly_rate].present?
        resource.hourly_rate = resource_params[:hourly_rate].gsub(",", ".")
      end
      resource.save
    end

    def before_update_callback
      params[:customer][:hourly_rate] = resource_params[:hourly_rate].gsub(",", ".") if resource_params[:hourly_rate].present?
      true
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(customer: [
        :tenant_id,
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
        :hourly_rate,
        :invoice_mail_out_option_key
      ])
    end
end
