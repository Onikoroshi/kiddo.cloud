class MaintenanceTools::ProductionSeeder

  attr_reader :center
  attr_reader :program

  def initialize
  end

  def self.seed
    puts "Preparing to seed production with starter data..."
    new.seed_all
  end

  def seed_all
    begin
      @center = Center.where(name: "Davis Kids Klub", subdomain: "daviskidsklub").first_or_create!
      @program = seed_program
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

  def seed_program
    Program.where(
      center: center,
      short_code: "dkk_summer_2018",
      name: "Davis Kids Klub Summer 2018",
      starts_at: Chronic.parse("6/11/2018"),
      ends_at: Chronic.parse("8/24/2018"),
      registration_opens: Chronic.parse("2/1/2018"),
      registration_closes: Chronic.parse("8/24/2018")
    ).first_or_create!
    # Program.where(
    #   center: center,
    #   short_code: "dkk_fall_2017",
    #   name: "Davis Kids Klub Fall 2017",
    #   starts_at: Chronic.parse("8/20/2017"),
    #   ends_at: Chronic.parse("6/20/2018")
    # ).first_or_create!
  end

  def seed_program_plans
    Plan.where(program: program, short_code: "week_full_day", display_name: "Full Day", days_per_week: 5, price: 229.00, plan_type: "weekly").first_or_create!
    Plan.where(program: program, short_code: "week_morning", display_name: "Morning", days_per_week: 5, price: 125.00, plan_type: "weekly").first_or_create!
    Plan.where(program: program, short_code: "week_afternoon", display_name: "Afternoon", days_per_week: 5, price: 125.00, plan_type: "weekly").first_or_create!
    Plan.where(program: program, short_code: "drop_full_day", display_name: "Full Day", days_per_week: 0, price: 55.00, plan_type: "drop_in").first_or_create!
    Plan.where(program: program, short_code: "drop_morning", display_name: "Morning", days_per_week: 0, price: 35.00, plan_type: "drop_in").first_or_create!
    Plan.where(program: program, short_code: "drop_afternoon", display_name: "Afternoon", days_per_week: 0, price: 35.00, plan_type: "drop_in").first_or_create!
    # Plan.where(program: program, short_code: "week_5", display_name: "Five Days a Week", days_per_week: 5, price: 285.00, plan_type: "weekly").first_or_create!
    # Plan.where(program: program, short_code: "week_4", display_name: "Four Days a Week", days_per_week: 4, price: 259.00, plan_type: "weekly").first_or_create!
    # Plan.where(program: program, short_code: "week_3", display_name: "Three Days a Week", days_per_week: 3, price: 229.00, plan_type: "weekly").first_or_create!
    # Plan.where(program: program, short_code: "week_2", display_name: "Two Days a Week", days_per_week: 2, price: 172.00, plan_type: "weekly").first_or_create!
    # Plan.where(program: program, short_code: "week_1", display_name: "One Day a Week", days_per_week: 1, price: 115.00, plan_type: "weekly").first_or_create!
    # Plan.where(program: program, short_code: "week_1_wed", display_name: "Wednesday; One Day a Week", days_per_week: 1, price: 129.00, plan_type: "weekly").first_or_create!
    # Plan.where(program: program, short_code: "sibling", display_name: "Sibling Club", days_per_week: 4, price: 40.00, plan_type: "weekly").first_or_create!
    # Plan.where(program: program, short_code: "drop_1", display_name: "Daily drop_in per day (M,T,TH,F)", days_per_week: 0, price: 30.00, plan_type: "drop_in").first_or_create!
    # Plan.where(program: program, short_code: "drop_1_wed", display_name: "Daily drop_in per day (Wednesday)", days_per_week: 0, price: 35.00, plan_type: "drop_in").first_or_create!
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
    # Location.where(name: "Birch Lane Elementary", center: center).first_or_create!
    # Location.where(name: "Korematsu Elementary", center: center).first_or_create!
    # Location.where(name: "M. Montgomery Elementary", center: center).first_or_create!
    # Location.where(name: "Patwin Elementary", center: center).first_or_create!
    # Location.where(name: "Pioneer Elementary", center: center).first_or_create!
    # Location.where(name: "Willett Elementary", center: center).first_or_create!
    location = Location.where(name: "North Davis School", center: center).first_or_create!
    ProgramLocation.where(program: program, location: location).first_or_create!
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
    DropIn.destroy_all
    Enrollment.destroy_all
    Plan.destroy_all
    Program.destroy_all
    Center.destroy_all
    Role.destroy_all
    Location.destroy_all
    User.destroy_all
  end

end
