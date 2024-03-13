class FindUnpaidEnrollments
  def self.send_unpaid_enrollments_report
    messages = []
    fewer_messages = []

    unpaid_enrollments = Enrollment.one_time.unpaid.includes(child: :account).references(:accounts)
    enroll_hash = unpaid_enrollments.to_a.group_by{|e| e.child.account.id}
    # messages << enroll_hash

    total_accounts = enroll_hash.count
    index = 1
    enroll_hash.each do |account_id, enrollments|
      messages << "processing account #{index} of #{total_accounts} (#{account_id})"

      if enrollments.count == 0
        messages << "no enrollments due for this account"
        next
      else
        messages << "#{enrollments.count} one-time enrollments unpaid for this account"
        fewer_messages << "#{enrollments.count} one-time enrollments unpaid for account # #{account_id}"
      end

      account = enrollments.first.child.account || Account.find_by(id: account_id)
      if account.blank?
        messages << "no associated account found"
        next
      end

      index += 1
    end

    TransactionalMailer.one_time_unpaid_payment_report(messages, [ "petertcormack@gmail.com" ]).deliver_now

    TransactionalMailer.one_time_unpaid_payment_report(fewer_messages, [ "petertcormack@gmail.com", "office@daviskidsklub.com", "admin@daviskidsklub.com" ]).deliver_now if fewer_messages.any?
  end
end
