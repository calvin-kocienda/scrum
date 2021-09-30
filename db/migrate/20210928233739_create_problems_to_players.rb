class CreateProblemsToPlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :problems_to_players do |t|
      t.integer :problemid
      t.integer :playerid
      t.integer :storyid

      t.timestamps
    end
  end
end
