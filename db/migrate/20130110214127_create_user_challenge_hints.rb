class CreateUserChallengeHints< ActiveRecord::Migration
  def change
    create_table :user_challenge_hints do |t|
      t.references :user, :challenge_hint
    end
  end
end
