class AddFlagDataToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :flag_data, :text
  end
end
