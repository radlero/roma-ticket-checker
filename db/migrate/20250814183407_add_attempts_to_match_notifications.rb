class AddAttemptsToMatchNotifications < ActiveRecord::Migration[8.0]
  def change
    add_column :match_notifications, :attempts, :integer
    add_column :match_notifications, :last_notified_at, :datetime
    add_column :match_notifications, :completed, :boolean
  end
end
