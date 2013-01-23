class RemoveHintFromChallenge < ActiveRecord::Migration
  def up
    remove_column :challenges, :hint
  end

  def down
    add_column :challenges, :hint, :text
  end
end
