class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.integer :project_id
      t.string :invoice_number
      t.string :currency
      t.integer :state
      t.integer :mail_out_state
      t.string :latest_mail_out_type
      t.string :locale
      t.string :external_reference
      t.string :description
      t.text :comment
      t.datetime :invoice_date
      t.datetime :payment_date
      t.string :address
      t.string :erp_guid
      t.boolean :show_lines_incl_vat
      t.string :invoice_template_id
      t.string :contact_guid
      t.integer :payment_condition_number_of_days
      t.string :payment_condition_type
      t.decimal :reminder_fee, precision: 10, scale: 2
      t.decimal :reminder_interest_rate, precision: 10, scale: 2
      t.decimal :total_excl_vat_in_dkk, precision: 10, scale: 2
      t.decimal :total_excl_vat, precision: 10, scale: 2
      t.decimal :total_incl_vat_in_dkk, precision: 10, scale: 2
      t.decimal :total_incl_vat, precision: 10, scale: 2
      t.boolean :is_mobile_pay_invoice_enabled
      t.boolean :is_penso_pay_enabled

      t.timestamps
    end
  end
end
