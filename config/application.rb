require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Kidsclub
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'exceptions', '**/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'enums', '**/')]
    config.eager_load_paths << "#{Rails.root}/lib"
    config.assets.paths << "#{Rails.root}/app/assets"

    config.time_zone = "Pacific Time (US & Canada)"

    config.active_job.queue_adapter = :async
  end
end
