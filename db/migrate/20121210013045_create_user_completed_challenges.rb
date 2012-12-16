class CreateUserCompletedChallenges < ActiveRecord::Migration
  def change
    create_table :user_completed_challenges do |t|
      t.integer :user_id
      t.integer :challenge_id
      t.integer :points

      t.timestamps
    end
  end
end