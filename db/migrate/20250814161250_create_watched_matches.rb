class CreateWatchedMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :watched_matches do |t|
      t.string :match_name

      t.timestamps
    end
  end
end
