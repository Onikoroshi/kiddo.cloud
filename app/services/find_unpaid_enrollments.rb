class FindUnpaidEnrollments
  def self.send_unpaid_enrollments_report
    messages = []
    unpaid_enrollments = Enrollment.one_time.unpaid.includes(child: :account).references(:accounts)
    enroll_hash = unpaid_enrollments.to_a.group_by{|e| e.child.account.id}
    messages << enroll_hash

    total_accounts = enroll_hash.count
    index = 1
    enroll_hash.each do |account_id, enrollments|
      messages << "processing account #{index} of #{total_accounts} (#{account_id})"

      if enrollments.count == 0
        messages << "no enrollments due for this account"
        next
      else
        messages << "#{enrollments.count} one-time enrollments unpaid for this account"
      end

      account = enrollments.first.child.account || Account.find_by(id: account_id)
      if account.blank?
        messages << "no associated account found"
        next
      end
    end

    ap messages
    # TransactionalMailer.one_time_unpaid_payment_report(messages).deliver_now
  end
end
