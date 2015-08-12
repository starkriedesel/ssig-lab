class AddTypeToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :submit_type, :integer, null: false, default: 0
    add_column :challenges, :launch_type, :integer, null: false, default: 0
  end
end
