class AddNumToStory < ActiveRecord::Migration[6.1]
  def change
    add_column :stories, :num, :integer
  end
end
