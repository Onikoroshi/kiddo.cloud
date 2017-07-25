namespace :launch do
  desc "Loads initial data for DKK into production"
  task :seed_production => :environment do
    ProductionSeeder.seed
  end
