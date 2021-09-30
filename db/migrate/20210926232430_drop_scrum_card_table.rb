class DropScrumCardTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :scrum_cards
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
