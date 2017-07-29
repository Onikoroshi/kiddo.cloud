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
      @center = Center.where(name: "Davis Kids Klub").first_or_create!
      @program = seed_program
      seed_program_plans
    rescue => e
      puts e.message
      puts e.backtrace
    end
    puts "Completed production seed."
  end

  def seed_program
    Program.where(
      center: center,
      name: "Davis Kids Klub Fall 2017",
      starts_at: Chronic.parse("8/20/2017"),
      ends_at: Chronic.parse("6/20/2018")
    ).first_or_create!
  end

  def seed_program_plans
    Plan.where(program: program, name: "Five Days a Week", days_per_week: 5, price: 285.00, plan_type: "weekly").first_or_create!
    Plan.where(program: program, name: "Four Days a Week", days_per_week: 4, price: 259.00, plan_type: "weekly").first_or_create!
    Plan.where(program: program, name: "Three Days a Week", days_per_week: 3, price: 229.00, plan_type: "weekly").first_or_create!
    Plan.where(program: program, name: "Two Days a Week", days_per_week: 2, price: 172.00, plan_type: "weekly").first_or_create!
    Plan.where(program: program, name: "One Day a Week", days_per_week: 1, price: 115.00, plan_type: "weekly").first_or_create!
    Plan.where(program: program, name: "Wednesday; One Day a Week", days_per_week: 1, price: 129.00, plan_type: "weekly").first_or_create!
    Plan.where(program: program, name: "Sibling Club", days_per_week: 4, price: 40.00, plan_type: "weekly").first_or_create!
    Plan.where(program: program, name: "Daily drop-in per day (M,T,TH,F)", days_per_week: 0, price: 30.00, plan_type: "drop-in").first_or_create!
    Plan.where(program: program, name: "Daily drop-in per day (Wednesday)", days_per_week: 0, price: 35.00, plan_type: "drop-in").first_or_create!
  end

  def backout
    Program.first.destroy
    Plan.destroy_all
  end

end
