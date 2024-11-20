class AddFieldsToCustomer < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :external_reference, :string
    add_column :customers, :is_person, :boolean
    add_column :customers, :is_member, :boolean
    add_column :customers, :is_debitor, :boolean
    add_column :customers, :is_creditor, :boolean
    add_column :customers, :country_key, :string
    add_column :customers, :webpage, :string
    add_column :customers, :att_person, :string
    add_column :customers, :payment_condition_type, :string
    add_column :customers, :payment_condition_number_of_days, :string
    add_column :customers, :member_number, :string
    add_column :customers, :company_status, :string
    add_column :customers, :vat_region_key, :string
    add_column :customers, :invoice_mail_out_option_key, :string
  end
end
