class CustomersController < MortimerController
  private
    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:customer).permit(:tenant_id, :name, :street, :zipcode, :city, :phone, :email, :vat_number, :ean_number)
    end
end
