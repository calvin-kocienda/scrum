class AddRealIdToProblemsToPlayer < ActiveRecord::Migration[6.1]
  def change
    add_column :problems_to_players, :realid, :integer
  end
end
