namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on"
  task send_late_checkin_alerts: :environment do
    puts "Sending late checkin alerts.."
    LateCheckinNotifier.new.execute
    puts "Complete."
  end
end
