class CreateStoriesToPlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :stories_to_players do |t|
      t.integer :storyid
      t.integer :playerid
      t.integer :work

      t.timestamps
    end
  end
end
