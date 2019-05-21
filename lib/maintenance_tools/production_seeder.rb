class MaintenanceTools::ProductionSeeder

  attr_reader :center
  attr_reader :program_summer, :program_fall, :program_tkk

  def initialize
    @center = Center.where(name: "Davis Kids Klub", subdomain: "daviskidsklub").first_or_create!
  end

  def self.seed
    puts "Preparing to seed production with starter data..."
    new.seed_all
  end

  def seed_all
    begin
      seed_roles
      seed_programs
      seed_program_plans
      seed_roles
      seed_users
      seed_locations
    rescue => e
      puts e.message
      puts e.backtrace
    end
    puts "Completed production seed."
  end

  def seed_roles
    # Roles are based on identity. For example, I can "act in" a role of staff.
    role_names = ["super_admin", "director", "staff", "parent"]
    role_names.each do |role_name|
      Role.where(name: role_name).first_or_create!
    end
  end

  def seed_programs
    seed_summer_program
    seed_fall_program
    seed_tkk_program
  end

  def seed_summer_program
    @program_summer = Program.where(
      center: center,
      name: "Summer Recreation Camp 2018",
      starts_at: Chronic.parse("6/11/2018"),
      ends_at: Chronic.parse("8/24/2018"),
      registration_opens: Chronic.parse("2/1/2018"),
      registration_closes: Chronic.parse("8/24/2018"),
      registration_fee: 50.0,
      change_fee: 49.0,
      earliest_payment_offset: -15,
      latest_payment_offset: 14,
      program_type: "summer",
      allowed_grades: Grades.new.collection
    ).first_or_create!
  end

  def seed_fall_program
    @program_fall = Program.where(
      center: center,
      name: "School Year 2018",
      starts_at: Chronic.parse("8/20/2018"),
      ends_at: Chronic.parse("6/20/2019"),
      registration_opens: Chronic.parse("5/10/2018"),
      registration_closes: Chronic.parse("6/2/2019"),
      registration_fee: 50.0,
      change_fee: 49.0,
      earliest_payment_offset: -15,
      latest_payment_offset: 14,
      program_type: "fall",
      allowed_grades: Grades.new.other_grades
    ).first_or_create!
  end

  def seed_tkk_program
    @program_tkk = Program.where(
      center: center,
      name: "TKK",
      starts_at: Chronic.parse("8/20/2018"),
      ends_at: Chronic.parse("6/20/2019"),
      registration_opens: Chronic.parse("5/10/2018"),
      registration_closes: Chronic.parse("6/2/2019"),
      registration_fee: 50.0,
      change_fee: 49.0,
      earliest_payment_offset: -15,
      latest_payment_offset: 14,
      program_type: "fall",
      allowed_grades: Grades.new.tkk_grades
    ).first_or_create!
  end

  def seed_program_plans
    seed_summer_program_plans
    seed_fall_program_plans
    seed_tkk_program_plans
  end

  def seed_summer_program_plans
    Plan.where(program: program_summer, display_name: "Full Day", days_per_week: 5, price: 229.00, plan_type: "weekly", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_summer, display_name: "Morning", days_per_week: 5, price: 125.00, plan_type: "weekly", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_summer, display_name: "Afternoon", days_per_week: 5, price: 125.00, plan_type: "weekly", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_summer, display_name: "Full Day", days_per_week: 1, price: 55.00, plan_type: "drop_in", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_summer, display_name: "Morning", days_per_week: 1, price: 35.00, plan_type: "drop_in", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_summer, display_name: "Afternoon", days_per_week: 1, price: 35.00, plan_type: "drop_in", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
  end

  def seed_fall_program_plans
    Plan.where(program: program_fall, display_name: "Five Days a Week", days_per_week: 5, price: 285.00, plan_type: "contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: true).first_or_create!
    Plan.where(program: program_fall, display_name: "Four Days a Week", days_per_week: 4, price: 259.00, plan_type: "contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: true).first_or_create!
    Plan.where(program: program_fall, display_name: "Three Days a Week", days_per_week: 3, price: 229.00, plan_type: "contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: true).first_or_create!
    Plan.where(program: program_fall, display_name: "Two Days a Week", days_per_week: 2, price: 172.00, plan_type: "contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: true).first_or_create!
    Plan.where(program: program_fall, display_name: "One Day a Week", days_per_week: 1, price: 115.00, plan_type: "contract", monday: true, tuesday: true, wednesday: false, thursday: true, friday: true, saturday: false, sunday: false, deduce: true).first_or_create!
    Plan.where(program: program_fall, display_name: "Wednesday; One Day a Week", days_per_week: 1, price: 129.00, plan_type: "contract", monday: false, tuesday: false, wednesday: true, thursday: false, friday: false, saturday: false, sunday: false, deduce: true).first_or_create!
    Plan.where(program: program_fall, display_name: "Sibling Club", days_per_week: -1, price: 40.00, plan_type: "sibling_club", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: true).first_or_create!
    Plan.where(program: program_fall, display_name: "(M, T, TH, F)", days_per_week: 1, price: 30.00, plan_type: "drop_in", monday: true, tuesday: true, wednesday: false, thursday: true, friday: true, saturday: false, sunday: false, deduce: true).first_or_create!
    Plan.where(program: program_fall, display_name: "(Wednesday)", days_per_week: 1, price: 35.00, plan_type: "drop_in", monday: false, tuesday: false, wednesday: true, thursday: false, friday: false, saturday: false, sunday: false, deduce: true).first_or_create!
  end

  def seed_tkk_program_plans
    Plan.where(program: program_tkk, display_name: "7:30 am - 8:15 am", days_per_week: -1, price: 79.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_tkk, display_name: "11:50 am - 3:15 pm", days_per_week: -1, price: 280.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_tkk, display_name: "3:10 pm - 6:10 pm", days_per_week: -1, price: 290.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_tkk, display_name: "7:30 am - 11:50 am", days_per_week: -1, price: 360.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_tkk, display_name: "11:50 am - 6:00 pm", days_per_week: -1, price: 540.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
    Plan.where(program: program_tkk, display_name: "7:30 am - 11:50 am & 3:10 pm - 6:10 pm", days_per_week: -1, price: 600.00, plan_type: "full_day_contract", monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: false, sunday: false, deduce: false).first_or_create!
  end

  def seed_roles
    Role.where(name: "super_admin").first_or_create!
    Role.where(name: "director").first_or_create!
    Role.where(name: "staff").first_or_create!
    Role.where(name: "parent").first_or_create!
  end

  def seed_users
    center = Center.find_by(subdomain: "daviskidsklub")
    u = User.create!(
      email: "daviskidsklub@aol.com",
      first_name: "Lynda",
      last_name: "Yancher",
      center: center,
      password: "asdfasdf",
      password_confirmation: "asdfasdf"
    )

    u.roles << Role.find_by(name: "super_admin")

    u = User.create!(
      email: "petertcormack@gmail.com",
      first_name: "Peter",
      last_name: "Cormack",
      center: center,
      password: "asdfasdf",
      password_confirmation: "asdfasdf"
    )

    u.roles << Role.find_by(name: "super_admin")

    u = User.create!(
      email: "ian.kilpatrick@gmail.com",
      first_name: "Ian",
      last_name: "kilpatrick",
      center: center,
      password: "asdfasdf",
      password_confirmation: "asdfasdf"
    )

    u.roles << Role.find_by(name: "super_admin")
  end

  def seed_locations
    seed_fall_locations
    seed_summer_locations
    seed_tkk_locations
  end

  def seed_fall_locations
    fall_names = ["Birch Lane Elementary", "Korematsu Elementary", "M. Montgomery Elementary", "Patwin Elementary", "Pioneer Elementary", "Willett Elementary", "North Davis School"]

    fall_names.each do |name|
      location = Location.where(name: name, center: center).first_or_create!
      ProgramLocation.where(program: program_fall, location: location).first_or_create!
    end
  end

  def seed_summer_locations
    summer_names = ["North Davis School"]
    summer_names.each do |name|
      location = Location.where(name: name, center: center).first_or_create!
      ProgramLocation.where(program: program_summer, location: location).first_or_create!
    end
  end

  def seed_tkk_locations
    summer_names = ["Pioneer Elementary"]
    summer_names.each do |name|
      location = Location.where(name: name, center: center).first_or_create!
      ProgramLocation.where(program: program_tkk, location: location).first_or_create!
    end
  end


  # def seed_stripe
  #   program.plans.each do |p|
  #     begin
  #       Stripe::Plan.retrieve("dkk_#{p.short_code}")
  #     rescue => e
  #       plan = Stripe::Plan.create(
  #         :name => "#{program.name} #{p.display_name}",
  #         :id => "dkk_#{p.short_code}",
  #         :interval => "month",
  #         :currency => "usd",
  #         :amount => p.price.to_i * 100,
  #       )
  #       puts "Created Stripe Plan: #{plan.name}"
  #     end
  #   end
  # end

  def backout
    CareItem.destroy_all
    DropIn.destroy_all
    Enrollment.destroy_all
    Child.destroy_all
    Parent.destroy_all
    User.destroy_all
    Plan.destroy_all
    Program.destroy_all
    Center.destroy_all
    Role.destroy_all
    Permission.destroy_all
    Location.destroy_all
  end

end
