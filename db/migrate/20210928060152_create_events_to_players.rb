class CreateEventsToPlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :events_to_players do |t|
      t.integer :storyid
      t.integer :playerid
      t.boolean :completed

      t.timestamps
    end
  end
end
