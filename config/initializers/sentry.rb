Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.environments = %w[beta production]
  config.processors -= [Raven::Processor::PostData] # Removes the PostData filter
end
