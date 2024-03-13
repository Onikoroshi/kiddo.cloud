namespace :scheduler do
  desc "Called by the Heroku scheduler add-on. Finds everyone who owes a recurring payment and attempts to make a charge in Stripe, sending an email and marking them as unpaid if that fails"
  task process_recurring_payments: :environment do

    messages = []
    fewer_messages = []

    begin
      due_enrollments = Enrollment.alive.recurring.due_by_today.includes(child: :account).references(:accounts)
      enroll_hash = due_enrollments.to_a.group_by{|e| e.child.account.id}
      # messages << enroll_hash

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
        messages << "total of #{total} due"

        success = false

        begin
          charge = nil

          if total != Money.new(0) # could be either positive or negative
            stripe_customer = StripeCustomerService.new(account).find_customer
            if stripe_customer.present?
              charge = Stripe::Charge.create(
                :amount => (total * 100).to_i,
                :currency => "usd",
                :customer => stripe_customer.id,
              )
            elsif enrollments.any?{ |enrollment| enrollment.requires_payment_information? }
              # just in case the call above doesn't throw an exception
              raise "Could not find Stripe Customer for id #{account.gateway_customer_id}"
            end
          end

          transaction = Transaction.create!(
            account: account,
            transaction_type: TransactionType[:recurring],
            gateway_id: charge.present? ? charge.id : "",
            amount: total,
            paid: true,
            itemizations: Hash.new
          )

          enrollments.each do |enrollment|
            enrollment.craft_enrollment_transactions(transaction)
          end

          success = true
        rescue => e
          messages << "Error with account #{account_id}"
          messages << e.message
          messages << e.backtrace

          fewer_messages << "Error with account #{account_id}"
          fewer_messages << e.message
          fewer_messages << e.backtrace
        end

        unless success
          fewer_messages << "Account (#{account_id}) payment of #{total} failed."
          enrollments.each do |enrollment|
            messages << "marking enrollment #{enrollment.id} unpaid"
            fewer_messages << "marking enrollment #{enrollment.id} unpaid"
            enrollment.update_attribute(:paid, false)
          end
        end

        if total != Money.new(0) # Don't notify unless actually tried to charge something
          if success
            TransactionalMailer.successful_recurring_payment(account).deliver_now
          else
            TransactionalMailer.failed_recurring_payment(account).deliver_now
          end
        else
          messages << "total of #{total} is 0, so customer not notified."
        end

        index += 1
      end
    rescue => e
      messages << e.message
      messages << e.backtrace

      fewer_messages << e.message
      fewer_messages << e.backtrace
    end

    TransactionalMailer.recurring_payment_report(messages, [ "petertcormack@gmail.com" ]).deliver_now
    TransactionalMailer.recurring_payment_report(fewer_messages, [ "petertcormack@gmail.com", "office@daviskidsklub.com", "admin@daviskidsklub.com" ]).deliver_now if fewer_messages.any?

    FindUnpaidEnrollments.send_unpaid_enrollments_report
  end

  desc "This task is called by the Heroku scheduler add-on"
  task send_late_checkin_alerts: :environment do
    puts "Sending late checkin alerts.."
    LateCheckinNotifier.new.execute
    puts "Complete."
  end
end
