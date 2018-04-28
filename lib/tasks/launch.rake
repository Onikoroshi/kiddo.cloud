namespace :launch do
  task :enable_all_send_waivers => :environment do
    Account.update_all(mail_agreements: true)
  end

  task :initialize_enrollment_transaction_descriptions => :environment do
    EnrollmentTransaction.find_each do |et|
      et.update_attribute(:description, et.enrollment.to_short)
    end
  end

  task :update_signup_and_change_fees => :environment do
    Transaction.find_each do |transaction|
      transaction.itemizations.keys.each do |key|
        key_string = key.to_s
        if key_string == "one_time_signup_fee" # original
          ap "#{key_string} is an original change fee"
          summer_program = Program.first
          transaction.itemizations["signup_fee_#{summer_program.id}"] = transaction.itemizations[key]
          transaction.itemizations.delete(key)
        elsif key_string.starts_with?("One Time Signup Fee for ") # first try
          ap "#{key_string} is a signup fee"
          target_program = Program.find_by(name: key_string.gsub("One Time Signup Fee for ", ""))
          transaction.itemizations["signup_fee_#{target_program.id}"] = transaction.itemizations[key]
          transaction.itemizations.delete(key)
        elsif key_string.starts_with?("Change Fee for ")
          ap "#{key_string} is a change fee"
          target_program = Program.find_by(name: key_string.gsub("Change Fee for ", ""))
          transaction.itemizations["signup_fee_#{target_program.id}"] = transaction.itemizations[key]
          transaction.itemizations.delete(key)
        else
          ap "no match for #{key_string}"
        end
      end

      transaction.save!
    end
  end

  desc "Initialize all the objects necessary for fall 2018"
  task :initialize_fall_2018 => :environment do
    seeder = MaintenanceTools::ProductionSeeder.new
    seeder.seed_fall_program
    seeder.seed_fall_program_plans
    seeder.seed_fall_locations
  end

  # already done the below
  desc "Update program fees and customer transactions"
  task :fix_program_fees_and_transactions => :environment do
    ap "hello"
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

  desc "Loads initial data for DKK into production"
  task :seed_production => :environment do
    MaintenanceTools::ProductionSeeder.seed
  end
end
