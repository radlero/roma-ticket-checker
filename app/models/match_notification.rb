class MatchNotification < ApplicationRecord
  attribute :attempts, :integer, default: 0
  attribute :completed, :boolean, default: false
end
