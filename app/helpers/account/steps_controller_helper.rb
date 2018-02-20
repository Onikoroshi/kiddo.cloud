module Account::StepsControllerHelper
  def plan_selection_path(plan_type, account)
    if plan_type.drop_in?
      new_account_dashboard_enrollment_path(account, plan_type: plan_type.to_s)
    elsif plan_type.weekly?
      new_account_dashboard_enrollment_path(account, plan_type: plan_type.to_s)
    else
      edit_account_attendance_selection_path(account)
    end
  end

  def program_week_options(program)
    weeks = []

    curr_monday = nil
    (program.starts_at..program.ends_at).each do |date|
      if date.monday?
        curr_monday = date
      elsif date.friday?
        weeks << "#{curr_monday} to #{date}"
        curr_monday = nil
      end
    end

    weeks
  end
end
