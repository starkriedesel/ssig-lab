class ChangeChallengeDescriptionColumnType < ActiveRecord::Migration
  def up
    change_column :challenges, :description, :text
  end
  def down
    change_column :challenges, :description, :string
  end
end
