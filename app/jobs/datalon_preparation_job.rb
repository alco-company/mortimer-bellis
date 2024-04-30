class DatalonPreparationJob < ApplicationJob
  queue_as :default

  #
  # account:          is the account
  # last_payroll_at:  is the last date to include
  # update_payroll:   is boolean true|false to update the last_payroll_at on account and team
  #
  def perform(**args)
    begin
      super(**args)
      switch_locale do
        last_payroll_at = args[:last_payroll_at]
        update_payroll = args[:update_payroll]
        run_job last_payroll_at, update_payroll
      end
    rescue => exception
      say exception
      false
    end
  end

  def run_job(last_payroll_at, update_payroll)
    tmpfiles = []

    output = PunchCard.lon_export_to_csv(last_payroll_at, update_payroll)
    persist tmpfiles, output, "csv"
    AccountMailer.with(rcpt: Current.account, tmpfiles: tmpfiles).lon_email.deliver_later
  end


  # we cannot use Tempfile because GC will delete the file before we are done with it
  #
  def persist(tmpfiles, output, format)
    output.each_with_index do |o, i|
      mark = DateTime.now.strftime("%s")
      tmpfile = Rails.root.join("tmp", "lon_#{i}_#{mark}.#{format}")
      tmpfiles << tmpfile
      file = File.open tmpfile, "wb"
      file.write o
      file.close
    end
  end
end
