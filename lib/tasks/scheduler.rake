namespace :scheduler do
  desc "Called by the Heroku scheduler add-on. Finds everyone who owes a recurring payment and attempts to make a charge in Stripe, sending an email and marking them as unpaid if that fails"
  task process_recurring_payments: :environment do
    messages = []
    
    begin
      due_enrollments = Enrollment.alive.active.recurring.due_by_today.includes(child: :account).references(:accounts)
      enroll_hash = due_enrollments.to_a.group_by{|e| e.child.account.id}
      messages << enroll_hash

      total_accounts = enroll_hash.count
      index = 1
      enroll_hash.each do |account_id, enrollments|
        messages << "processing account #{index} of #{total_accounts} (#{account_id})"

        if enrollments.count == 0
          messages << "no enrollments due for this account"
          next
        else
          messages << "#{enrollments.count} enrollments due for this account"
        end

        account = enrollments.first.child.account || Account.find_by(id: account_id)
        if account.blank?
          messages << "no associated account found"
          next
        end

        total = enrollments.inject(Money.new(0)){ |sum, enrollment| sum + Money.new(enrollment.amount_due_today) }

        success = false
        if total <= Money.new(0)
          messages << "enrollments #{enrollments.map(&:id).join(" ")} have $0 due."
          enrollments.each do |enrollment|
            enrollment.set_next_target_and_payment_date!
          end

          # don't send an email if they didn't actually owe anything
          next
        elsif account.gateway_customer_id.present?
          messages << "total of #{total} due"

          stripe_customer = StripeCustomerService.new(account).find_customer
          if stripe_customer.present?
            begin
              charge = Stripe::Charge.create(
                :amount => (total * 100).to_i,
                :currency => "usd",
                :customer => stripe_customer.id,
              )

              transaction = Transaction.create!(
                account: account,
                transaction_type: TransactionType[:recurring],
                gateway_id: charge.id,
                amount: total,
                paid: true,
                itemizations: Hash.new
              )

              enrollments.each do |enrollment|
                enrollment.craft_enrollment_transactions(transaction)
              end

              success = true
            rescue => e
              messages << e.message
              messages << e.backtrace
            end
          end
        end

        if success
          TransactionalMailer.successful_recurring_payment(account).deliver_now
        else
          enrollments.each do |enrollment|
            messages << "marking enrollment #{enrollment.id} unpaid"
            enrollment.update_attribute(:paid, false)
          end
          TransactionalMailer.failed_recurring_payment(account).deliver_now
        end

        index += 1
      end
    rescue => e
      messages << e.message
      messages << e.backtrace
    end

    TransactionalMailer.recurring_payment_report(messages).deliver_now
  end

  desc "This task is called by the Heroku scheduler add-on"
  task send_late_checkin_alerts: :environment do
    puts "Sending late checkin alerts.."
    LateCheckinNotifier.new.execute
    puts "Complete."
  end
end
