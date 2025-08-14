class CreateMatchNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :match_notifications do |t|
      t.string :match_name
      t.datetime :match_date
      t.boolean :notified

      t.timestamps
    end
  end
end
