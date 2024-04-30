# frozen_string_literal: true

# module Datalon - used by ExportCsv to pull data from models 
# required to build paycheck export for Dataløn
#
# FORMATERING af løndata til Dataløn
# Kolonne A: Virksomhedsnr.
# Kolonne B: Løntermin
# Kolonne C: medarbejdernr.
# Kolonne D: Gruppen
# Kolonne E: Lønfeltet
# Kolonne F: Sats/beløb
#
# Vi har en arbejdsgiver med virksomhedsnummer 100111001. 
# Arbejdsgiveren har en medarbejder i termin 51. 
# Medarbejderen har lønnummer 0027. 
# Medarbejderen er indplaceret i gruppen kontoret. 
# Igen en måneds arbejde defineret ved 160,33 arbejdstimer. 
# Medarbejderen skal have kr. 25.000,00 i ferieberettiget løn. 
# Medarbejderen skal også beskattes af fri telefon på kr. 216.66.
#
# OUTPUT
# 100111001;51;0027;Kontoret;01;16033 - total hours
# 100111001;51;0027;Kontoret;02;2500000 - monthly salary
# 100111001;51;0027;Kontoret;12;10000 - decimal hours
# 100111001;51;0027;Kontoret;13;15000 - hourly salary
# 100111001;51;0027;Kontoret;14;4000 - decimal hours
# 100111001;51;0027;Kontoret;15;17500 - hourly salary - OT1
# 100111001;51;0027;Kontoret;42;21666
#
# https://bluegarden.zendesk.com/hc/da/articles/115002021765
#
module Datalon
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    #
    # return an array of CSV 'files' with the data
    def lon_export_to_csv(punches_settled_at, update_payroll)
      arr = []
      Current.account.teams.each do |team|
        ids = team.employees.pluck(:id)
        resources = lon_payroll_export team.name, team.punches_settled_at, punches_settled_at, ids
        arr << lon_to_csv(resources, punches_settled_at)
        if update_payroll
          punch_cards_to_update team.punches_settled_at, punches_settled_at, ids
          team.update punches_settled_at: punches_settled_at
          team.employees.update_all punches_settled_at: punches_settled_at
        end
      end
      arr
    end

    def lon_payroll_export(name, from_date, to_date, ids = nil)
      from_date = from_date || Date.parse("2024-05-04").beginning_of_day
      to_date = to_date || Date.today.end_of_day
      payroll_view(name, from_date, to_date, ids)
    end

    def punch_cards_to_update(from_date, to_date, ids = nil)
      from_date = from_date || Date.parse("2024-05-04").beginning_of_day
      to_date = to_date || Date.today.end_of_day
      PunchCard.where(id: punch_card_view(from_date, to_date, ids)).update_all punches_settled_at: to_date
    end

    #
    # this is NOT a materialized view - it's a regular query
    # if speed becomes an issue look here: https://pganalyze.com/blog/materialized-views-ruby-rails
    #
    def payroll_view(name, fd, td, ids = nil)
      where_ids = (ids.nil? or ids.empty?) ? " " : " AND employees.id IN (#{[ids].flatten.join(',')}) "
      PunchCard.find_by_sql <<-SQL
        SELECT
        SUM("payroll"."work_minutes") AS work_minutes,
        SUM("payroll"."ot1_minutes") AS ot1_minutes,
        SUM("payroll"."ot2_minutes") AS ot2_minutes,
        '#{name}' AS group_name,
        "employees"."payroll_employee_ident" AS emp_number,
        "employees"."id" AS emp_id,
        "employees"."name" AS emp_name
        FROM "punch_cards" AS "payroll"
        INNER JOIN "employees" ON "payroll"."employee_id" = "employees"."id"
        WHERE "payroll"."account_id" = #{Current.account.id} AND
        payroll.punches_settled_at IS NULL AND
        payroll.work_date >= '#{fd}' AND
        payroll.work_date <= '#{td}' #{ where_ids } 
  			GROUP BY "group_name", "employees"."payroll_employee_ident", "employees"."name", "employees"."id"
        ORDER BY "employees"."payroll_employee_ident"
      SQL
    end

    def punch_card_view(fd, td, ids = nil)
      where_ids = (ids.nil? or ids.empty?) ? " " : " AND employees.id IN (#{[ids].flatten.join(',')}) "
      PunchCard.find_by_sql <<-SQL
        SELECT
        "punch_cards"."id"
        FROM "punch_cards"
        INNER JOIN "employees" ON "punch_cards"."employee_id" = "employees"."id"
        WHERE "punch_cards"."account_id" = #{Current.account.id} AND
        punch_cards.punches_settled_at IS NULL AND
        punch_cards.work_date >= '#{fd}' AND
        punch_cards.work_date <= '#{td}' #{ where_ids }
      SQL
    end

    def lon_to_csv(resources, termin)
      require "csv"
      CSV.generate(col_sep: ";", encoding: "utf-8") do |csv|
        csv << lon_csv_header
        resources.each do |row|
          lon_csv_row row, csv, organisation: Current.account.lon_identification, termin: termin.strftime("%y%m"), group: row.group_name
        end
      end
    end
    #
    # csv_headers and csv_row are used by ExportCsv
    # describing the csv file to be generated
    #
    # both methods may be implemented on the model
    # if not then this default implementation is used
    #
    # Kolonne A: Virksomhedsnr.
    # Kolonne B: Løntermin
    # Kolonne C: medarbejdernr.
    # Kolonne D: Gruppen
    # Kolonne E: Lønfeltet
    # Kolonne F: Sats/beløb
    #
    def lon_csv_header(header = nil)
      %w[Virksomhedsnr Løntermin Medarbejdernr Gruppe Lønfelt Sats/beløb]
    end

    #
    # csv_row builds an array of values for the csv file row
    # this is used by ExportCsv
    #
    # 100111001;51;0027;Kontoret;01;16033 - total hours
    # 100111001;51;0027;Kontoret;02;2500000 - monthly salary
    # 100111001;51;0027;Kontoret;12;10000 - decimal hours
    # 100111001;51;0027;Kontoret;13;15000 - hourly salary
    # 100111001;51;0027;Kontoret;14;4000 - decimal hours
    # 100111001;51;0027;Kontoret;15;17500 - hourly salary - OT1
    #
    # løndele - https://bluegarden.zendesk.com/hc/da/articles/115002021765
    #
    def lon_csv_row(row, csv, args)
      hrs, min = (row.work_minutes + row.ot1_minutes + row.ot2_minutes).to_i.divmod 60
      min = min.to_f/60*100
      hrs = "%i%02i" % [ hrs, min ]
      emp = Employee.find(row.emp_id)
      csv << [ args[:organisation], args[:termin].to_i, row.emp_number, args[:group], "01", hrs ]
      generate_row args, csv, row, row.work_minutes, emp.get_hour_rate_cent, [ "12", "13" ]
      generate_row args, csv, row, row.ot1_minutes,  emp.get_ot1_hour_rate_cent, [ "16", "17" ] if row.ot1_minutes > 0
      generate_row args, csv, row, row.ot2_minutes,  emp.get_ot2_hour_rate_cent, [ "18", "19" ] if row.ot2_minutes > 0
    end

    def generate_row(args, csv, row, minutes, rate_cent, pay_ids)
      hrs, min = minutes.to_i.divmod 60
      min = min.to_f/60*100
      whrs = "%i%02i" % [ hrs, min ]
      csv << [ args[:organisation], args[:termin], row.emp_number, args[:group], pay_ids[0], whrs ]
      csv << [ args[:organisation], args[:termin], row.emp_number, args[:group], pay_ids[1], rate_cent ]
    end
  end
end
