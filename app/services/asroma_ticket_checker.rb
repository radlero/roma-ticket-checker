require 'httparty'
require 'nokogiri'

# AsromaTicketChecker encapsulates the logic for scraping
# https://www.asroma.com/en/tickets/men and finding matches
# that currently have tickets on sale.
class AsromaTicketChecker
  # URL of the AS Roma men’s ticket listing
  URL = 'https://www.asroma.com/en/tickets/men'.freeze

  def fetch_available_matches
    response = HTTParty.get(URL)
    return [] unless response.success?

    doc = Nokogiri::HTML.parse(response.body)
    matches_with_tickets = []

    doc.css('.asr-ticket-item').each do |item|
      cta_link = item.at_css('a.asr-ticket-listing_purchase-row__regular-cta-link')
      next unless cta_link

      date_text = item.at_css('.asr-ticket-item_date span')&.text&.strip
      time_text = item.at_css('.asr-ticket-item_date .match-time')&.text&.strip

      home_team = item.at_css('.asr-ticket-item_competition-teams_home-name')&.text&.strip
      away_team = item.at_css('.asr-ticket-item_competition-teams_away-name')&.text&.strip
      match_name = [home_team, away_team].compact.join(' vs ')

      href = cta_link['href']
      ticket_url = href.to_s
      if ticket_url.start_with?('/')
        ticket_url = "https://www.asroma.com#{ticket_url}"
      end

      matches_with_tickets << {
        name: match_name,
        date: [date_text, time_text].compact.join(' '),
        url: ticket_url
      }
    end

    matches_with_tickets
  rescue StandardError => e
    Rails.logger.error "AsromaTicketChecker error: #{e.message}"
    []
  end
end
