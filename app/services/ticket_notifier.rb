class TicketNotifier
  def self.notify(match)
    TicketMailer.ticket_available(match).deliver_now
    if ENV['TWILIO_ACCOUNT_SID'] && ENV['TWILIO_AUTH_TOKEN']
      client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
      client.messages.create(
        from: ENV['TWILIO_FROM_NUMBER'],
        to: ENV['USER_PHONE_NUMBER'],
        body: "Tickets available for #{match[:name]} on #{match[:date]}! #{match[:url]}"
      )
    end
  end
end
