namespace :launch do
  desc "Update program fees and customer transactions"
  task :fix_program_fees_and_transactions => :environment do
    Program.update_all(change_fee: 49.0)

    Transaction.find_each do |transaction|
      transaction.send(:initialize_receipt_number)
      ap "looking at transaction #{transaction.id} with receipt number #{transaction.receipt_number} from account #{transaction.account.id}"
      customer = StripeCustomerService.new(transaction.account).find_customer
      charges = Stripe::Charge.list(customer: transaction.account.gateway_customer_id, limit: 5)
      ap charges.map{|c| c.id}

      target_charge = charges.first
      transaction.update_attribute(:gateway_id, target_charge.id)
    end
  end
end
