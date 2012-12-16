class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags, :id => false, :primary_key => false do |t|
      t.integer :user_id
      t.integer :challenge_id
      t.string :value
      t.string :nonce

      t.timestamps
    end
    
    add_index :flags, [:user_id, :challenge_id], :unique => true
  end
end
