# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
tenant = Tenant.find_or_create_by!(name: "Mortimer", email: "info@mortimer.pro", locale: "da", time_zone: "Europe/Copenhagen", color: "bg-blue-200", tax_number: "N/A")
team = Team.find_or_create_by!(tenant: tenant, name: "Mortimer", email: "info@mortimer.pro", color: "bg-blue-200", locale: "en", time_zone: "UTC")
user = User.new(email: 'info@mortimer.pro', tenant: tenant, global_queries: true, team: team, pincode: '1000', role: 2, password: 'M0r71m3r!', password_confirmation: 'M0r71m3r!')
user.save!
