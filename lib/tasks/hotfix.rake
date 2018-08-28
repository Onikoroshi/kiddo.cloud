namespace :hotfix do
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
    seeder = MaintenanceTools::ProductionSeeder.new.seed_all_day_plans
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
