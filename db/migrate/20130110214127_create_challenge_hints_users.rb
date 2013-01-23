class CreateChallengeHintsUsers < ActiveRecord::Migration
  def change
    create_table :challenge_hints_users, :id => false do |t|
      t.references :challenge_hint, :user
    end
  end
end
