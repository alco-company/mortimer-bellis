module EmployeeInvitationsHelper
  def display_employee_invition_state_date invite
    dd = invite.completed_at || invite.seen_at || invite.invited_at ||  invite.updated_at
    dd.strftime("%d/%m/%Y %H:%M")
  end
end
