require "test_helper"

class EmployeeMailerTest < ActionMailer::TestCase
  test "report_state" do
    mail = EmployeeMailer.report_state
    assert_equal "Report state", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
