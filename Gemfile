source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "2.6.6"

gem 'devise', '4.4'
gem 'haml-rails', '~> 2.0'
gem 'wicked', '~> 1.3', '>= 1.3.1'
gem 'forgery', '~> 0.6.0'
gem 'seed-fu', '~> 2.3', '>= 2.3.6'
gem 'awesome_print', '~> 1.7'
gem 'flatpickr_rails'
gem 'pundit', '~> 1.1'
gem "font-awesome-rails"
gem "chronic"
gem 'shopify-money', '0.16.0'
gem "cocoon"
gem "stamp"
gem "stripe"
gem "kaminari"
gem "roo"
gem "classy_enum"
# Error Reporting
gem "sentry-raven"


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.1'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-tablesorter'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
gem "clipboard-rails"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # For easy test records
  gem "factory_girl_rails", "~> 4.8"
  # For generating fake data
  gem "faker", "~> 1.7.3"
  # Test suite
  gem "rspec-rails", "~> 3.6"
end

# Heroku
gem 'rails_12factor', group: [:production, :beta]

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Automatic Ruby code style checking tool
  gem "rubocop", "~> 0.49.1"
  gem "letter_opener"
  gem 'rails_db', '2.0.4'
end

group :test do
  # A gem providing "time travel" and "time freezing" capabilities for tests
  gem "timecop", "~> 0.9.0"
  gem 'rspec-activemodel-mocks'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
