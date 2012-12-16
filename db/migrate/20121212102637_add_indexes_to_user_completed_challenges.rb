class AddIndexesToUserCompletedChallenges < ActiveRecord::Migration
  def change
    #add_index :user_completed_challenges, :user_id
    #add_index :user_completed_challenges, :challenge_id
    add_index :user_completed_challenges, [:user_id, :challenge_id], :unique => true
  end
end
