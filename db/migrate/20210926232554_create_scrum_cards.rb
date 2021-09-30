class CreateScrumCards < ActiveRecord::Migration[6.1]
  def change
    create_table :scrum_cards do |t|
      t.string :title
      t.string :result
      t.string :rating
      t.string :cardtype

      t.timestamps
    end
  end
end
