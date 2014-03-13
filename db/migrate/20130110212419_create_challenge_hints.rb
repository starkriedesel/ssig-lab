class CreateChallengeHints < ActiveRecord::Migration
  def change
    create_table :challenge_hints do |t|
      t.integer :challenge_id
      t.text :hint_text
      t.integer :cost, default: 0

      t.timestamps
    end
  end
end
