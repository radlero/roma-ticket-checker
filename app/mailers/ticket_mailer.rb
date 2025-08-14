class TicketMailer < ApplicationMailer
  default from: 'youremail'  # change to a valid sender

  def ticket_available(match)
    @match = match

    mail(
      to: ENV['USER_EMAIL_ADDRESS'],
      subject: "Tickets available for #{@match[:name]}"
    )
  end
end
