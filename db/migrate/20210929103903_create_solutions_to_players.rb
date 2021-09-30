class CreateSolutionsToPlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :solutions_to_players do |t|
      t.integer :solutionid
      t.integer :playerid
      t.integer :storyid

      t.timestamps
    end
  end
end
