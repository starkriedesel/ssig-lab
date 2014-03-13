class CreateUserCompletedChallenges < ActiveRecord::Migration
  def change
    create_table :user_completed_challenges do |t|
      t.references :user, :challenge
      t.timestamps
    end
  end
end