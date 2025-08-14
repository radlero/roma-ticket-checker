class CheckTicketsJob < ApplicationJob
  queue_as :default
  MAX_ATTEMPTS = 3

  def perform
    checker = AsromaTicketChecker.new
    matches = checker.fetch_available_matches

    watched = WatchedMatch.pluck(:match_name).map { |n| normalize(n) }.to_set

    matches.each do |match|
      next unless watched.include?(normalize(match[:name]))

      match_date = safe_parse_datetime(match[:date])

      notif = MatchNotification.find_or_initialize_by(
        match_name: match[:name],
        match_date: match_date
      )

      notif.attempts  ||= 0
      notif.completed ||= false

      # stop if we've already sent 3 times
      next if notif.completed

      if notif.attempts < MAX_ATTEMPTS
        TicketNotifier.notify(match)

        notif.attempts += 1
        notif.notified = true
        notif.completed = true if notif.attempts >= MAX_ATTEMPTS
        notif.save!
      end
    end
  end

  private

  def normalize(name)
    name.to_s.downcase.strip.gsub(/\s+/, ' ')
  end

  def safe_parse_datetime(s)
    return nil if s.blank?
    DateTime.parse(s) rescue nil
  end
end
