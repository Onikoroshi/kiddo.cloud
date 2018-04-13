namespace :launch do
  desc "Loads initial data for DKK into production"
  task :seed_production => :environment do
    MaintenanceTools::ProductionSeeder.seed
  end

  desc "Initialize all the objects necessary for fall 2018"
  task :initialize_fall_2018 => :environment do
    seeder = MaintenanceTools::ProductionSeeder.new
    seeder.seed_fall_program
    seeder.seed_fall_program_plans
    seeder.seed_fall_locations
  end
end
