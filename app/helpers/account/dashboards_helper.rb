module Account::DashboardsHelper
  def enrollment_changes_message(account)
    if account.enrollment_changes.pending.count > 0
      "You have pending enrollment changes. #{link_to "Click Here", new_account_dashboard_payment_path(@account)} to finalize them!".html_safe
    elsif account.enrollments.alive.unpaid.count > 0
      "You have unpaid enrollments. #{link_to "Click Here", new_account_dashboard_payment_path(@account)} to pay for them!".html_safe
    else
      ""
    end
  end

  def display_itemization_title(original_key)
    chunks = original_key.to_s.split("_fee_")
    type = case chunks[0]
    when "signup"
      "One Time Signup Fee"
    when "change"
      "Change Fee"
    else
      chunks[0]
    end

    program = Program.find_by(id: chunks[1])
    program_name = program.present? ? " for #{program.name}" : ""

    "#{type}#{program_name}"
  end
end
