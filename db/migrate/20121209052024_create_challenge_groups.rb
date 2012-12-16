class CreateChallengeGroups < ActiveRecord::Migration
  def change
    create_table :challenge_groups do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
