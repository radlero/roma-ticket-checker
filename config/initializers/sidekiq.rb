require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  # Load the schedule from the YAML file when Sidekiq boots
  schedule_file = Rails.root.join('config', 'sidekiq_scheduler.yml')
  if File.exist?(schedule_file)
    config.on(:startup) do
      Sidekiq.schedule = YAML.load_file(schedule_file)
      Sidekiq::Scheduler.reload_schedule!
    end
  end
end