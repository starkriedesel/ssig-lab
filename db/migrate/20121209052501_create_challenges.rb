class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.string :name
      t.string :challenge_group_id
      t.string :url
      t.string :description
      t.integer :points
      t.text :hint

      t.timestamps
    end
    
    add_index :challenges, :challenge_group_id
  end
end
