
# roma-ticket-checker
Roma Ticket Checker is a Ruby on Rails + Sidekiq app that automatically monitors the AS Roma ticket page for selected football matches.
When tickets for your selected matches become available, the app sends you:

Email notifications (via Gmail SMTP)

SMS alerts (via Twilio, if configured)


You can:

Add/remove matches you want to monitor in the Rails console
Run the checker on your own laptop with Sidekiq Scheduler (e.g., every 10 or 30 minutes)
Avoid spam with built-in logic to send up to 3 alerts per match

Tech stack:

Ruby on Rails

Sidekiq + Sidekiq Scheduler

HTTParty + Nokogiri for scraping

ActionMailer (SMTP)

Twilio (optional)

Please make sure to setup in .env file / secrets file

USER_EMAIL_ADDRESS=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_FROM_NUMBER=
USER_PHONE_NUMBER=
SMTP_USERNAME=
SMTP_PASSWORD=

# To run sidekiq Scheduler 
bundle exec sidekiq -C config/sidekiq.yml

# List watched matches
WatchedMatch.all.pluck(:id, :match_name)

# Add (idempotent)
WatchedMatch.find_or_create_by!(match_name: "Roma vs Bologna")

# Add multiple
["Roma vs Torino", "Roma vs Inter"].each { |n| WatchedMatch.find_or_create_by!(match_name: n) }

# Update a watched match name
wm = WatchedMatch.find_by(match_name: "Roma vs Bologna")
wm.update!(match_name: "AS Roma vs Bologna") if wm

# Remove one watched match
WatchedMatch.where(match_name: "Roma vs Bologna").destroy_all
# or
WatchedMatch.destroy_by(match_name: "Roma vs Bologna")

# Remove all watched matches
WatchedMatch.delete_all

# List recent notifications
MatchNotification.order(created_at: :desc).limit(10).pluck(:match_name, :match_date, :attempts, :completed, :notified)

# Check if a specific match/date has a notification row
MatchNotification.exists?(match_name: "Roma vs Bologna")

# Clear notifications for a match (to re-test end-to-end)
MatchNotification.where(match_name: "Roma vs Bologna").delete_all

# Reset attempts for a match/date (if you added attempts/completed columns)
mn = MatchNotification.find_by(match_name: "Roma vs Bologna")
mn.update!(attempts: 0, completed: false) if mn

# Wipe all notifications (careful!)
MatchNotification.delete_all

# Run the job immediately (don’t wait for scheduler)
CheckTicketsJob.perform_now

# See Sidekiq Scheduler config (when sidekiq-scheduler is loaded)
Sidekiq.get_schedule
