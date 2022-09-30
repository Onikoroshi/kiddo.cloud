class FixBorkedEnrollmentTransactions
  def fix_everything!
    program = Program.find(45)
    enrollments = Enrollment.by_program(program)
    ap "looking at #{enrollments.count} enrollments"
    enrollments.find_each do |enrollment|
      ap "examining enrollment #{enrollment.id} for account #{enrollment.account.id}"

      program_start_date = enrollment.program.starts_at.to_date

      enrollment.enrollment_transactions.find_each do |enroll_trans|
        replace = enroll_trans.description_data
        start_date = replace["start_date"].to_date

        replace["stop_date"] = start_date < program_start_date ? program_start_date - 1.day : start_date.end_of_month

        enroll_trans.update_column(:description_data, replace)
      end

      enrollment.set_next_target_and_payment_date!
    end
  end
end
