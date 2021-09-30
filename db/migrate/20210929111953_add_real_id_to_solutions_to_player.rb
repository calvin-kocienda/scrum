class AddRealIdToSolutionsToPlayer < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions_to_players, :realid, :integer
  end
end
