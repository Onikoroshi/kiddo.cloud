namespace :launch do
  desc "Update program fees and customer transactions"
  task :fix_program_fees_and_transactions => :environment do
    Program.update_all(change_fee: 49.0)

    # need to downcase genders so that they work properly with the ClassyEnum
    Child.find_each do |child|
      old_gender = child.gender.to_s
      child.update_attribute(:gender, old_gender.downcase)
    end

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