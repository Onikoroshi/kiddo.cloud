namespace :hotfix do
  task :fix_prorating => :environment do
    target_date = Time.zone.today.beginning_of_month

    enrollment_transactions = EnrollmentTransaction.joins(enrollment: {plan: :program}).joins(enrollment: {child: :account}).where(plans: {plan_type: PlanType.recurring.map(&:to_s)}).where("enrollment_transactions.amount > ? AND enrollment_transactions.target_date = ?", 0, target_date).distinct

    report = {}
    not_less = 0

    enrollment_transactions.find_each do |et|
      account = et.enrollment.child.account
      account_email = et.enrollment.child.account.primary_email
      child_name = et.enrollment.child.full_name
      program_name = et.enrollment.plan.program.name
      enrollment_description = et.enrollment.to_short
      correct_cost = et.enrollment.cost_for_date(target_date).to_money
      already_paid = et.amount.to_money

      if already_paid < correct_cost
        ap "---------------------------------------"
        ap "description: #{enrollment_description}"
        ap "this amount: #{already_paid}"
        ap "target amount: #{correct_cost}"
        report[account_email] = {} if report[account_email].nil?

        report[account_email][child_name] = {} if report[account_email][child_name].nil?
        report[account_email][child_name][program_name] = {} if report[account_email][child_name][program_name].nil?

        prev_paid = Money.new(0)
        prev_to_charge = Money.new(0)

        existing_entry = report[account_email][child_name][program_name][enrollment_description]
        if existing_entry.present?
          prev_paid = existing_entry["already_paid"].to_money
          ap "previously paid #{prev_paid}"
          prev_to_charge = existing_entry["amount_to_charge"].to_money
          ap "previously to be charged: #{prev_to_charge}"
          already_paid += prev_paid
        end

        ap "when added with other amount: #{already_paid} - comparing to #{correct_cost}"
        if already_paid >= correct_cost
          report[account_email][child_name][program_name].delete(enrollment_description)

          if report[account_email][child_name][program_name].blank?
            report[account_email][child_name].delete(program_name)
          end

          if report[account_email][child_name].blank?
            report[account_email].delete(child_name)
          end

          ap "account charge before: #{report[account_email]["account_charge"]}"
          ap "removing #{prev_to_charge}"
          report[account_email]["account_charge"] -= prev_to_charge
          ap "account charge after: #{report[account_email]["account_charge"]}"
          report[account_email].delete("account_charge") if report[account_email]["account_charge"].blank? || report[account_email]["account_charge"] <= Money.new(0)

          report.delete(account_email) if report[account_email].blank?
        else
          amount_to_charge = correct_cost - already_paid

          report[account_email][child_name][program_name][enrollment_description] = {
            "correct_cost" => correct_cost,
            "already_paid" => already_paid,
            "amount_to_charge" => amount_to_charge,
            "et" => et
          }

          report[account_email]["account_charge"] = Money.new(0) if report[account_email]["account_charge"].nil?
          ap "account charge before: #{report[account_email]["account_charge"]}"

          if prev_to_charge > Money.new(0)
            ap "removing prev charge #{prev_to_charge}"
            report[account_email]["account_charge"] -= prev_to_charge
            ap "account_charge after: #{report[account_email]["account_charge"]}"
          end

          ap "adding #{amount_to_charge}"
          report[account_email]["account_charge"] += amount_to_charge
          ap "account charge after: #{report[account_email]["account_charge"]}"
        end
      else # this enrollment transaction by itself pays it off, so remove anything if existing
        if report[account_email].present?
          if report[account_email][child_name].present?
            if report[account_email][child_name][program_name].present?
              report[account_email][child_name][program_name].delete(enrollment_description)
            end

            if report[account_email][child_name][program_name].blank?
              report[account_email][child_name].delete(program_name)
            end
          end

          if report[account_email][child_name].blank?
            report[account_email].delete(child_name)
          end
        end

        if report[account_email].blank?
          report.delete(account_email)
        end
      end
    end

    report.each do |account_email, account_data|
      begin
        user = User.find_by(email: account_email)
        account = user.account

        if account_data["account_charge"].blank?
          report[account_email]["error"] = "No amount given"
          next
        end

        target_charge = account_data["account_charge"].to_f

        unless target_charge > 0.0
          report[account_email]["error"] = "amount #{target_charge} not greater than 0"
          next
        end

        stripe_customer = StripeCustomerService.new(account).find_customer
        if stripe_customer.present?
          charge = Stripe::Charge.create(
            :amount => (target_charge * 100).to_i,
            :currency => "usd",
            :customer => stripe_customer.id,
          )
        else
          # just in case the call above doesn't throw an exception
          raise "Could not find Stripe Customer for id #{account.gateway_customer_id}"
        end

        transaction = Transaction.create!(
          account: account,
          transaction_type: TransactionType[:recurring],
          gateway_id: charge.present? ? charge.id : "",
          amount: target_charge,
          paid: true,
          itemizations: Hash.new
        )

        account_data.each do |child_name, child_data|
          next if ["error", "account_charge"].include?(child_name)

          child_data.each do |program_name, program_data|
            program_data.each do |enrollment_description, enrollment_data|
              et = enrollment_data["et"]
              difference = enrollment_data["amount_to_charge"].to_money

              created_transaction = EnrollmentTransaction.create(enrollment_id: et.enrollment.id, my_transaction_id: transaction.id, amount: difference, target_date: target_date, description_data: {"description" => et.enrollment.to_short, "start_date" => target_date, "stop_date" => [target_date.end_of_month, et.enrollment.ends_at].min})
            end
          end
        end

      rescue => e
        report[account_email]["error"] = "Exception: #{e.message}\n#{e.backtrace}"
      end
    end

    ap "==========================================="

    report.each do |account_email, account_data|
      ap "Account: #{account_email}"
      account_data.each do |child_name, child_data|
        next if ["error", "account_charge"].include?(child_name)

        ap "  Child: #{child_name}"
        child_data.each do |program_name, program_data|
          ap "    Program: #{program_name}"
          program_data.each do |enrollment_description, enrollment_data|
            ap "      Enrollment: #{enrollment_description}"
            et = enrollment_data["et"]
            correct_cost = enrollment_data["correct_cost"].to_money
            difference = correct_cost - et.amount
            ap "        Paid #{et.amount} instead of #{correct_cost}; #{account_data["error"].blank? ? "successfully" : "could not be"} #{difference <= 0 ? "refunded" : "charged"} #{difference}"
          end
        end
      end

      if account_data["error"].present?
        ap "  Error: #{account_data["error"]}"
      end

      if account_data["account_charge"].present?
        ap "  Account charged a total of #{account_data["account_charge"]}"
      end
    end
  end

  task :report_prorating => :environment do
    target_date = Time.zone.today.beginning_of_month

    enrollment_transactions = EnrollmentTransaction.joins(enrollment: {plan: :program}).joins(enrollment: {child: :account}).where(plans: {plan_type: PlanType.recurring.map(&:to_s)}).where("enrollment_transactions.amount > ? AND enrollment_transactions.target_date = ?", 0, target_date).distinct

    enrollment_ids = enrollment_transactions.pluck("enrollments.id").uniq
    child_ids = enrollment_transactions.pluck("children.id").uniq
    account_ids = enrollment_transactions.pluck("accounts.id").uniq

    # emails = []
    paid_less = {}
    paid_more = {}
    paid_equal = {}

    enrollment_transactions.find_each do |et|
      ap "======== #{et.id} ========"
      # account_emails = et.enrollment.child.account.all_emails
      account_email = et.enrollment.child.account.primary_email
      child_name = et.enrollment.child.full_name
      enrollment_description = et.enrollment.to_short
      program_name = et.enrollment.plan.program.name
      correct_cost = et.enrollment.cost_for_date(target_date).to_f

      if et.amount.to_f < correct_cost
        # emails += account_emails
        paid_less[account_email] = {} if paid_less[account_email].nil?
        paid_less[account_email][child_name] = {} if paid_less[account_email][child_name].nil?
        paid_less[account_email][child_name][program_name] = {} if paid_less[account_email][child_name][program_name].nil?
        paid_less[account_email][child_name][program_name][enrollment_description] = {
          "correct_cost" => correct_cost,
          "et" => et
        }
      elsif et.amount.to_f == correct_cost
        paid_equal[account_email] = {} if paid_equal[account_email].nil?
        paid_equal[account_email][child_name] = {} if paid_equal[account_email][child_name].nil?
        paid_equal[account_email][child_name][program_name] = {} if paid_equal[account_email][child_name][program_name].nil?
        paid_equal[account_email][child_name][program_name][enrollment_description] = {
          "correct_cost" => correct_cost,
          "et" => et
        }
      elsif et.amount.to_f > correct_cost
        paid_more[account_email] = {} if paid_more[account_email].nil?
        paid_more[account_email][child_name] = {} if paid_more[account_email][child_name].nil?
        paid_more[account_email][child_name][program_name] = {} if paid_more[account_email][child_name][program_name].nil?
        paid_more[account_email][child_name][program_name][enrollment_description] = {
          "correct_cost" => correct_cost,
          "et" => et
        }
      end
    end

    # ap emails.uniq.join(", ")

    ap "#{paid_less.count} accounts that paid less"
    ap "#{paid_more.count} accounts that paid more"
    ap "#{paid_equal.count} accounts that were correct"

    paid_less.each do |account_email, account_data|
      account_data.each do |child_name, child_data|
        child_data.each do |program_name, program_data|
          program_data.each do |enrollment_description, enrollment_data|
            et = enrollment_data["et"]
            correct_cost = enrollment_data["correct_cost"].to_money
            difference = correct_cost - et.amount
            ap "#{account_email} - #{child_name} paid #{et.amount} instead of #{correct_cost}; should be #{difference <= 0 ? "refunded" : "charged"} #{difference} for #{enrollment_description} in program #{program_name}"
          end
        end
      end
    end
  end

  task :update_generalized_discounts => :environment do
    total = Discount.count
    index = 1
    Discount.find_each do |discount|
      ap "#{discount.month.present? ? "processing" : "skipping"} discount #{index} of #{total} (#{discount.id}) for plan #{discount.plan.full_display_name} in program #{discount.plan.program.name}"

      year = discount.plan.program.name.gsub("School Year ", "").to_i

      if discount.month == "august" # this august
        discount.update_attribute(:starts_on, Time.zone.parse("#{year}-08-02").to_date.beginning_of_month)
        discount.update_attribute(:stops_on, Time.zone.parse("#{year}-08-02").to_date.end_of_month)
        ap "  changed #{discount.month} to #{discount.starts_on}-#{discount.stops_on}"
        discount.update_attribute(:month, nil)
      elsif discount.month == "june" # next june
        year += 1
        discount.update_attribute(:starts_on, Time.zone.parse("#{year}-06-02").to_date.beginning_of_month)
        discount.update_attribute(:stops_on, Time.zone.parse("#{year}-06-02").to_date.end_of_month)
        ap "  changed #{discount.month} to #{discount.starts_on}-#{discount.stops_on}"
        discount.update_attribute(:month, nil)
      else
        ap "  month #{discount.month} not one of them!"
      end
      index += 1
    end
  end

  task :disable_locations => :environment do
    names = [
      "Birch Lane Elementary",
      "César Chávez Elementary",
      "Patwin Elementary",
      "Pioneer Elementary",
      "Willett Elementary"
    ]

    locations = Location.where(name: names)
    program = Program.for_fall.first

    program_locations = ProgramLocation.where(program_id: program.id, location_id: locations.pluck(:id))

    program_locations.each do |prloc|
      ap "#{prloc.program.name} #{prloc.location.name} #{prloc.available}"
    end

    program_locations.update_all(available: false)

    program_locations.each do |prloc|
      prloc.reload
      ap "#{prloc.program.name} #{prloc.location.name} #{prloc.available}"
    end
  end

  task :add_all_day_plans => :environment do
    program_fall = Program.find_by(name: "TKK All Day Care at Pioneer Elementary")
    if program_fall.blank?
      ap "No program with name 'TKK All Day Care at Pioneer Elementary'"
      return
    end

    Plan.where(program: program_fall, display_name: "7:30 am - 8:15 am", days_per_week: 5, price: 79.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_fall, display_name: "11:50 am - 3:15 pm", days_per_week: 5, price: 280.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_fall, display_name: "3:10 pm - 6:10 pm", days_per_week: 5, price: 290.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_fall, display_name: "7:30 am - 11:50 am", days_per_week: 5, price: 360.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_fall, display_name: "11:50 am - 6:00 pm", days_per_week: 5, price: 540.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_fall, display_name: "7:30 am - 11:50 am & 3:10 pm - 6:10 pm", days_per_week: 5, price: 600.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
  end

  task :fix_enrollment_days => :environment do
    index = 1
    total = Enrollment.by_plan_type("sibling_club").count
    Enrollment.by_plan_type("sibling_club").find_each do |enrollment|
      ap "Enrollment #{index} of #{total}: #{enrollment.id} for account #{enrollment.child.account.id}"
      if enrollment.plan.blank?
        ap "No Plan!"
        next
      end

      enrolled_days = enrollment.enrolled_days
      plan_days = enrollment.plan.allowed_days

      matching_days = enrolled_days & plan_days
      extra_days = enrolled_days - plan_days

      if extra_days.any?
        ap "enrolled:"
        ap enrolled_days

        ap "allowed:"
        ap plan_days

        ap "matching days:"
        ap matching_days

        ap "extra days:"
        ap extra_days
      end

      index += 1
    end
  end
end
