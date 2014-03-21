class AddVisibleToChallengeGroup < ActiveRecord::Migration
  def change
    add_column :challenge_groups, :visible, :integer, default: 1
  end
end
