namespace :hotfix do
  task :fix_prorating => :environment do
    target_date = Time.zone.today.beginning_of_month

    enrollment_transactions = EnrollmentTransaction.joins(enrollment: {plan: :program}).joins(enrollment: {child: :account}).where(plans: {plan_type: PlanType.recurring.map(&:to_s)}).where("enrollment_transactions.amount > ? AND enrollment_transactions.target_date = ?", 0, target_date).distinct

    enrollment_ids = enrollment_transactions.pluck("enrollments.id").uniq
    child_ids = enrollment_transactions.pluck("children.id").uniq
    account_ids = enrollment_transactions.pluck("accounts.id").uniq

    ap "people who have paid something for June:"
    ap "#{enrollment_ids.count} separate enrollments"
    ap "#{child_ids.count} children"
    ap "#{account_ids. count} accounts"

    paid_less = {}
    paid_more = {}
    paid_equal = {}

    enrollment_transactions.find_each do |et|
      account_email = et.enrollment.child.account.primary_email.to_s
      child_name = et.enrollment.child.full_name
      enrollment_description = et.enrollment.to_short
      program_name = et.enrollment.plan.program.name
      correct_cost = et.enrollment.cost_for_date(target_date).to_f

      if et.amount.to_f < correct_cost
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

    ap "#{paid_less.count} accounts that paid less"
    ap "#{paid_more.count} accounts that paid more"
    ap "#{paid_equal.count} accounts that were correct"

    paid_more.each do |account_email, account_data|
      account_data.each do |child_name, child_data|
        child_data.each do |program_name, program_data|
          program_data.each do |enrollment_description, enrollment_data|
            difference = correct_cost - et.amount
            ap "#{account_email} - #{child_name} paid #{et.amount} instead of #{correct_cost}; should be #{difference <= 0 ? "refunded" : "charged"} #{difference} for #{enrollment_description} in program #{program_name}"
          end
        end
      end
    end

    ap "-----------------"

    paid_more.each do |account_email, account_data|
      account_data.each do |child_name, child_data|
        child_data.each do |program_name, program_data|
          program_data.each do |enrollment_description, enrollment_data|
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
