namespace :scheduler do
  desc "Called by the Heroku scheduler add-on. Finds everyone who owes a recurring payment and attempts to make a charge in Stripe, sending an email and marking them as unpaid if that fails"
  task process_recurring_payments: :environment do
    enrollments = Enrollment.alive.active.recurring.due_by_today.includes(child: :account).references(:accounts)
    enroll_hash = enrollments.to_a.group_by{|e| e.child.account.id}
    ap enroll_hash
    return nil

    total = accounts.count
    index = 1
    accounts.find_each do |account|
      ap "processing account #{index} of #{total} (#{account.id})"
      enrollments = account.enrollments.alive.recurring.due_by_today
      ap "#{enrollments.count} enrollments due"
      total = enrollments.total_amount_due_today
      ap "total of #{total} due"

      success = false
      if total <= Money.new(0)
        enrollments.find_each do |enrollment|
          enrollment.set_next_target_and_payment_date!
        end
      elsif account.gateway_customer_id.present?
        stripe_customer = StripeCustomerService.new(account).find_customer
        if stripe_customer.present?
          begin
            charge = Stripe::Charge.create(
              :amount => (total * 100).to_i,
              :currency => "usd",
              :customer => customer.id,
            )

            transaction = Transaction.create!(
              account: @account,
              transaction_type: TransactionType[:recurring],
              gateway_id: charge.id,
              amount: amount,
              paid: true,
              itemizations: calculator.itemizations
            )

            calculator.enrollments.each do |enrollment|
              enrollment.craft_enrollment_transactions(transaction)
            end

            success = true
          rescue => e
            ap e.message
            ap e.backtrace
          end
        end
      end

      unless success
        # send failure email
      end

      index += 1
    end
  end

  desc "This task is called by the Heroku scheduler add-on"
  task send_late_checkin_alerts: :environment do
    puts "Sending late checkin alerts.."
    LateCheckinNotifier.new.execute
    puts "Complete."
  end
end
