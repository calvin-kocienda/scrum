class CreateExtraDices < ActiveRecord::Migration[6.1]
  def change
    create_table :extra_dices do |t|
      t.integer :playerid
      t.boolean :enabled

      t.timestamps
    end
  end
end
