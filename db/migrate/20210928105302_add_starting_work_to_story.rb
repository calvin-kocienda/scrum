class AddStartingWorkToStory < ActiveRecord::Migration[6.1]
  def change
    add_column :stories, :starting_work, :integer
  end
end
